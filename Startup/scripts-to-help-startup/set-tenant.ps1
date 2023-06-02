function f-settenant {
   param(
       [Parameter()]
       [string]$domain
   )

   if ($domain -eq "") {
       $domain = Read-Host "What is the domain you want to connect to?"
   }

   $domainName = $domain
   $global:connectmsoldomain = $domainName

   $customers = @(Get-AzureADSubscribedSku | Where-Object {
       $_.CapabilityStatus -eq "PartnerManaged" -and $_.ServicePlans.ServiceName -eq "EXCHANGE" -and $_.ServicePlans.ServiceCapability -eq "Email" -and $_.ServicePlans.AppliesTo -contains $domainName
   })

   $global:cid = $customers.TenantId

   Write-Host "$($customers.Name) selected."

   Write-Host "You are logged in on"
   Write-Host "Tenant: $($customers.Name)"
   Write-Host "TenantID: $cid"
   Write-host ".onmicrosoft domain: $domainName"
}