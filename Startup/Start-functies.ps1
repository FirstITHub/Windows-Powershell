#Greetings of the user
$userloggedin = (Get-ItemProperty "HKCU:\\Software\\Microsoft\\Office\\Common\\UserInfo\\").UserName
Write-Host "Heey $userloggedin. Success vandaag!"


#The other scripts that is running in here comes one at the time at the place here#
#Get the modules
# List of modules to install
$modules = Get-Module

$modulesToInstall = @(
    "MSGraph",
    "AzureADPreview",
    "ExchangeOnlineManagement"
)

# Install modules if they are not already present
$modulesToInstall | ForEach-Object {
    $moduleName = $_
    if ($moduleName -notin $modules) {
        Install-Module -Name $moduleName -AcceptLicense:$true -Confirm:$false
        import-module -name $modulename
    }
    else {
    }
}

#This script is the first in line to start te powershell of First NV
Connect-AzureAD
#get-info of the logged in tenant
$tenantname = (Get-AzureADTenantDetail).Displayname
$tenantid = (Get-AzureADTenantDetail).objectid
$MsolDomains = Get-MsolDomain -TenantId $tenantid

        $regex = '^[^.]*\.onmicrosoft\.com$'
        $Domainname = $MsolDomains |
            Where-Object Name -Match $regex |
            Select-Object -ExpandProperty Name |
            Select-Object -First 1

#write it out

Write-Host "You are logged in on"
Write-Host "Tenant: $tenantname"
Write-Host "TenantID: $tenantid"
Write-host ".onmicrosoft domain: $domainname"

#load menu
cd "C:\Users\sjoerd.kanon\Github\Windows-Powershell\devel\startup\scripts-to-help-startup"
#. "./start-menu.ps1"

#get-tenantinfo
cd "C:\Users\sjoerd.kanon\Github\Windows-Powershell\devel\startup\scripts-to-help-startup"
. "./get-tenantinfo.ps1"

#load-tenant
. "./script-to-help-startup/set-tenant.ps1"