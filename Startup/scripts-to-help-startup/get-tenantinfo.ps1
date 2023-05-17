function f-gettenant
     {
      param(
         [Parameter()]
         [string]$domain
      )   
   if ($domain -eq "")
      {
         $domain = Read-Host "Wat is het domein waarmee je wil verbinden?" 
      }
      $domainname = $domain
      $global:connectmsoldomain = $domainname
    $Customers = @()
    $Customers = @(Get-MsolPartnerContract -DomainName $domainname)
 
    $global:cid = $Customers.tenantid
         
    Write-Host "$($Customers.name) selected."

    Write-Host "You are logged in on"
    Write-Host "Tenant: $($Customers.name)"
    Write-Host "TenantID: $cid"
    Write-host ".onmicrosoft domain: $domainname"
    }   