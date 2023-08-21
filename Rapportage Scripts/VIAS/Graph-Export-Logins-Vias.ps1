#configuration options for App registered login to Azure for Graphs

$appsecret = "Gpz8Q~.mmdIyWwz3maj3yKPMtM_iTrMNSBLZJcGc" 
$companyid = "9d1b1b22-a9e0-4852-a110-fec4fd757c6e"
$applicationid = "b275626f-27cc-4bec-a88f-24d808d8ade5"
$SecuredPasswordPassword = ConvertTo-SecureString `
-String $appsecret -AsPlainText -Force

$ClientSecretCredential = New-Object `
-TypeName System.Management.Automation.PSCredential `
-ArgumentList $ApplicationId, $SecuredPasswordPassword

Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
mkdir C:\temp -ErrorAction SilentlyContinue
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
Write-Host "Begin login"
# Authenticate and connect to Microsoft Graph

Connect-MgGraph -TenantID $companyid -ClientSecretCredential $ClientSecretCredential

Write-Host "Begin search"

# Set the start and end dates for the report (e.g., current month)

$startDate = (Get-Date).AddMonths(-1).ToString("yyyy-MM-dd")

$endDate = (Get-Date).ToString("yyyy-MM-dd")

$today = (Get-Date).ToString("yyyy-MM-dd")


# Retrieve sign-in logs for the specified date range

$signIns = Get-MgAuditLogSignIn -All -Filter "createdDateTime ge $startDate and createdDateTime le $endDate and ConditionalAccessStatus eq 'success'" | Select-Object -Property UserDisplayName, UserPrincipalName, CreatedDateTime, @{Name="Country"; Expression={$_.Location.CountryOrRegion}}, @{Name="City"; Expression={$_.Location.City}}
$count = $signins.count

Write-Host "There are $count"

# Filter for logins abroad and select relevant properties

$signInsAbroad = $signIns | Where-Object { $_.Country -ne 'BE'}

$countabroad = $signInsAbroad.count

Write-Host "There are $countabroad"




# Export the sign-in logs to a CSV file

$exportPath = "C:\temp\Vias-$today.csv"

$signInsAbroad | Export-Csv -Path $exportPath -NoTypeInformation




# Confirmation message

Write-Host "The sign-in logs for logins abroad in the last month have been exported to $exportPath."




# Disconnect from Microsoft Graph

Disconnect-MgGraph

# Sender's and recipient's email addresses
$senderEmail = "rapport-logins@vias.be"
$recipientEmail = "sjoerd.kanon@first.eu"

# Email subject and body
$subject = "CSV Report - Succeeded logins of 1 month"
$body = @"
<html>Hallo,</br></br>Hierbij het rapport voor de succesvolle logins</br></br></br>Dit bericht is via een automatische script verzonden</html>
"@

# SMTP server settings
$smtpServer = "vias-be.mail.protection.outlook.com"
$smtpPort = 25
$smtpUsername = "your.smtp.username"
$smtpPassword = "your.smtp.password"

# Path to the CSV file
$csvFilePath = "C:\path\to\your\file.csv"

# Send the email with the CSV attachment
Send-MailMessage -From $senderEmail -To $recipientEmail -Subject $subject -Body $body -BodyAsHtml -SmtpServer $smtpServer -Port $smtpPort -Attachments $exportPath