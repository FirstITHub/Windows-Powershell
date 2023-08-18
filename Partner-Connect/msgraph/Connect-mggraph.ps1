$appsecret = "Gpz8Q~.mmdIyWwz3maj3yKPMtM_iTrMNSBLZJcGc" 
$companyid = "9d1b1b22-a9e0-4852-a110-fec4fd757c6e"
$applicationid = "b275626f-27cc-4bec-a88f-24d808d8ade5"
$SecuredPasswordPassword = ConvertTo-SecureString `
-String $appsecret -AsPlainText -Force

$ClientSecretCredential = New-Object `
-TypeName System.Management.Automation.PSCredential `
-ArgumentList $ApplicationId, $SecuredPasswordPassword



Connect-MgGraph -TenantID $companyid -ClientSecretCredential $ClientSecretCredential