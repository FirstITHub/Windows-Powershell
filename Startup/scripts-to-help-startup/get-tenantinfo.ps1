function f-gettenant
     {
      
      $global:cid = $Customers.tenantid
      $domainname = $domain
      $global:connectmsoldomain = $domainname
    $Customers = @()
    $Customers = @(Get-MsolPartnerContract -TenantId $cid)
    Write-Host "You are logged in on"
    Write-Host "Tenant: $($Customers.name)"
    Write-Host "TenantID: $cid"
    Write-host "domain: $domainname"
    }   