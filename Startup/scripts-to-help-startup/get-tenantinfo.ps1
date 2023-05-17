function f-gettenant
     {
      
      $global:cid = $Customers.tenantid
     Customers = @()
    $Customers = @(Get-MsolPartnerContract -DomainName $domain)
    Write-Host "You are logged in on"
    Write-Host "Tenant: $($Customers.name)"
    Write-Host "TenantID: $cid"
    Write-host "domain: $domainname"
    }   