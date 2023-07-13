if ($env:COMPUTERNAME -eq "bnchv001") {
    Write-Host "This script cannot be run on bnchv001."
}
else {
# Get the list of user profiles
$UserProfiles = Get-ChildItem -Path "C:\Users" -Exclude "Administrator", "Public", "Default" | Sort-Object -Property LastWriteTime -Descending

# Keep the last two user profiles that were created
$UserProfilesToKeep = $UserProfiles[0..1]

# Remove all other user profiles
foreach ($UserProfile in $UserProfiles) {
 if ($UserProfile -notin $UserProfilesToKeep) {
  Write-Host "Removing user profile: $($UserProfile.Name)..."
  Remove-Item -Path $UserProfile.FullName -Recurse -Force
 }
}
}