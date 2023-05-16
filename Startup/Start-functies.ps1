#Greetings of the user
$userloggedin = (Get-ItemProperty "HKCU:\\Software\\Microsoft\\Office\\Common\\UserInfo\\").UserName
Write-Host "Heey $userloggedin. Success vandaag!"

#Get-Path#Baseline script will removed if script is finished
."./baseline-functies.ps1"

#The other scripts that is running in here comes one at the time at the place here#
#Get the modules
$modules = Get-Module
##line of script to install the modules
if ($module -in $modules){
    Get-Module
}
#This script is the first in line to start te powershell of First NV
. "./Connect-M365.ps1"


function prompt {
    $p = Split-Path -leaf -path (Get-Location)
    "$p> "
   }
