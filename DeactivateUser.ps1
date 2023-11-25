# Prompt user for username
$username = Read-Host -Prompt "Enter the username"

# Check if the user exists
$user = Get-ADUser -Filter {SamAccountName -eq $username}
if (!$user) {
    Write-Host "User $username not found."
    exit
}

# Display changes for confirmation
Write-Host "Changes to be made for user $username:"
Write-Host "1. Remove all groups besides 'Domain Users'"
Write-Host "2. Remove phone, ipphone, company, title, and organization fields."
Write-Host "3. Move user to OU=Deactivated Users,OU=StaffandFaculty,DC=scs,DC=sterlingschool,DC=org"
Write-Host "4. Disable the account."

# Prompt for confirmation
$confirmation = Read-Host -Prompt "Do you want to proceed with these changes? (Y/N)"
if ($confirmation -ne 'Y') {
    Write-Host "Script execution aborted."
    exit
}

# 1. Remove all groups besides "Domain Users"
$groupsToRemove = $user.MemberOf | Where-Object {$_ -ne "Domain Users"}
foreach ($group in $groupsToRemove) {
    Remove-ADGroupMember -Identity $group -Members $username -Confirm:$false
}
Write-Host "Removed user from groups."

# 2. Remove specified attributes
$user | Set-ADUser -Clear "phone", "ipphone", "company", "title", "organization"
Write-Host "Cleared specified attributes."

# 3. Move user to the specified OU
$targetOU = "OU=Deactivated Users,OU=StaffandFaculty,DC=scs,DC=sterlingschool,DC=org"
Move-ADObject -Identity $user.DistinguishedName -TargetPath $targetOU
Write-Host "Moved user to $targetOU."

# 4. Disable the account
Disable-ADAccount -Identity $username
Write-Host "Disabled user account."

Write-Host "Script completed successfully."
