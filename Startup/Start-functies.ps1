#Greetings of the user
$userloggedin = (Get-ItemProperty "HKCU:\\Software\\Microsoft\\Office\\Common\\UserInfo\\").UserName
Write-Host "Heey $userloggedin. Success vandaag!"


#The other scripts that is running in here comes one at the time at the place here#
#Get the modules
# List of modules to install
$modules = Get-Module

$modulesToInstall = @(
    "MSGraph",
    "AzureAD",
    "ExchangeOnlineManagement"
)

# Install modules if they are not already present
$modulesToInstall | ForEach-Object {
    $moduleName = $_
    if ($moduleName -notin $modules) {
        Install-Module -Name $moduleName -Force
    }
}

#This script is the first in line to start te powershell of First NV
. "./Connect-M365.ps1"

#Get-info of tenant were are you working
Write-Host = You are working on $tenant