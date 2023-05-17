function f-gettenant
     {
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
      Write-host "Domain: $domainname"
    }   