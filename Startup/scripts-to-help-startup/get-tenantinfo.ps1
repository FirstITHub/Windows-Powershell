function f-gettenant
     {
      $Customers = @(Get-MsolPartnerContract -DomainName $domainname)
    Write-Host "You are logged in on"
    Write-Host "Tenant: $($Customers.name)"
    Write-Host "TenantID: $cid"
    Write-host "domain: $domainname"
    }   