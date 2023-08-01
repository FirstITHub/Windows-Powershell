# Install modules if they are not already present
$modules = Get-Module

$modulesToInstall = @(
    "MSGraph",
    "Microsoft.Graph"
)

$modulesToInstall | ForEach-Object {
    $moduleName = $_
    if ($moduleName -notin $modules) {
# Install the required module (if not already installed)
        Install-Module -Name $moduleName -Confirm:$false
        import-module -name $modulename
    }
    else {
    }

}
# Authenticate and connect to Microsoft Graph
$klant = Read-host "Wat is de klantnaam?"
$tenantid = Read-host "Plak hier de tenant-id in van de klant"
Connect-MgGraph -TenantID $tenantid -Scopes "AuditLog.Read.All"
Select-MgProfile "beta"


# Set the start and end dates for the report (e.g., current month)

$startDate = (Get-Date).AddMonths(-6).ToString("yyyy-MM-dd")

$endDate = (Get-Date).ToString("yyyy-MM-dd")

$today = (Get-Date).ToString("yyyy-MM-dd")


# Retrieve sign-in logs for the specified date range

$signIns = Get-MgAuditLogSignIn -All -Filter "createdDateTime ge $startDate and createdDateTime le $endDate" |  Select-Object -Property UserDisplayName, UserPrincipalName, CreatedDateTime, @{Name="Country"; Expression={$_.Location.CountryOrRegion}}, @{Name="City"; Expression={$_.Location.City}}

$count = $signins.count

Write-Host "There are $count"

# Filter for logins abroad and select relevant properties

$signInsAbroad = $signIns | Where-Object { $_.Country -ne 'BE'}

$countabroad = $signInsAbroad.count

Write-Host "There are $countabroad"




# Export the sign-in logs to a CSV file

$exportPath = "$env:OnedriveCommercial\Documenten\$klant-$today.csv"

$signInsAbroad | Export-Csv -Path $exportPath -NoTypeInformation




# Confirmation message

Write-Host "The sign-in logs for logins abroad in the last month have been exported to $exportPath."




# Disconnect from Microsoft Graph

Disconnect-MgGraph