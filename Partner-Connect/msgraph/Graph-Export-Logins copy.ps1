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
        Install-Module -Name $moduleName -AcceptLicense:$false -Confirm:$false
        import-module -name $modulename
    }
    else {
    }

}
# Authenticate and connect to Microsoft Graph

Connect-MgGraph -TenantId 9d1b1b22-a9e0-4852-a110-fec4fd757c6e -Scopes "AuditLog.Read.All"




# Set the start and end dates for the report (e.g., current month)


# Retrieve sign-in logs for the specified date range

$auditLogs = Get-MgAuditLogSignIn -Filter "riskDetail eq 'RiskySignIn'"


$auditLogs.value | Select-Object UserDisplayName, UserPrincipalName, IPAddress, RiskDetail, RiskLevel, RiskState


# Export the sign-in logs to a CSV file

$exportPath = "$env:OnedriveCommercial\Documenten\GroupSuerickx.csv"

$auditLogs.value | Export-Csv -Path $exportPath -NoTypeInformation




# Confirmation message

Write-Host "The sign-in logs for logins abroad in the last month have been exported to $exportPath."




# Disconnect from Microsoft Graph

Disconnect-MgGraph