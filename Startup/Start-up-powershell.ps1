#Greetings of the user
$userloggedin = (Get-ItemProperty "HKCU:\\Software\\Microsoft\\Office\\Common\\UserInfo\\").UserName
Write-Host "Heey $userloggedin. Success vandaag!"

#This script is the first in line to start te powershell of Company Name#
."./baseline-functies.ps1"
#The other scripts that is running in here comes one at the time at the place here#
#Get the modules
##line of script to install the modules