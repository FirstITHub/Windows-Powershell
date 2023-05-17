#Greetings of the user
$userloggedin = (Get-ItemProperty "HKCU:\\Software\\Microsoft\\Office\\Common\\UserInfo\\").UserName
Write-Host "Heey $userloggedin. Success vandaag!"

#Get-Path#Baseline script will removed if script is finished
."./baseline-functies.ps1"

#The other scripts that is running in here comes one at the time at the place here#
#Get the modules
# List of modules to install
$modules = Get-Module

$modulesToInstall = @(
    "Module1",
    "Module2",
    "Module3"
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


function prompt {
    $p = Split-Path -leaf -path (Get-Location)
    "$p> "
   }
