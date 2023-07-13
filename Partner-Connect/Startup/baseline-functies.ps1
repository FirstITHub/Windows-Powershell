Connect-MsolService 
if ($realname) { Write-Host "Heey $realname. Succes vandaag"}
else{ Write-Host "Heey $upn. Succes vandaag!"}
#$userloggedin = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
#Write-Host "Heey $userloggedin. Success vandaag!"

function Show-Menu
{
    param (
        [string]$Title = 'Modules laden'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Exchange Online"
    Write-Host "2: Azure AD"
    Write-Host "3: Microsoft Teams"
    Write-Host "4: MS Graph"
    Write-Host "Q: Press 'Q' to quit."
}
 
function f-exocheck {

   try {
        # Run the Get-AcceptedDomain cmdlet
        Get-AcceptedDomain -Identity $connectmsoldomain -ErrorAction Stop | Out-Null
    } 
    
    catch {
        # If an error occurs, run the Connect-EXOPSSession cmdlet to connect to Exchange Online
        Connect-ExchangeOnline -UserPrincipalName $upn -DelegatedOrganization $connectmsoldomain
    }
   }  
   
 function f-menu
 {
    Show-Menu –Title 'My Menu'
 $selection = Read-Host "Welke modules wil je laden"
 switch ($selection)
 {
     '1' {
         'Verbinding maken met Exchange Online'
         $MsolDomains = Get-MsolDomain -TenantId $cid

        $regex = '^[^.]*\.onmicrosoft\.com$'
        $Domainname = $MsolDomains |
            Where-Object Name -Match $regex |
            Select-Object -ExpandProperty Name |
            Select-Object -First 1

         Connect-ExchangeOnline -UserPrincipalName $upn -DelegatedOrganization $domainname
     } '2' {
         'You chose option #2'
         Import-Module AzureADpreview
         Connect-AzureAD -AccountId $upn -TenantId $cid
     } '3' {
         'You chose option #3'
         Import-Module MicrosoftTeams
         Connect-MicrosoftTeams -tenantid $cid
     } '4' {
         'You chose option #4'
        Import-Module -Name MSGraphFunctions
        Import-Module -Name IntuneBackupAndRestore
        Update-MSGraphEnvironment -AuthUrl "https://login.microsoftonline.com/$cid"
        Connect-MSGraph
     } 
     'q' {
         return
     }
 }}


 
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
         
    Write-Host "$($Customers.name) selected. User the -tenantid `$cid parameter to run MSOL commands for this customer."
    }   

  
 function f-copyofsentitems
 {
   f-exocheck 
 (Get-Mailbox).primarysmtpaddress | set-mailbox -MessageCopyForSentAsEnabled $True
 }

 function f-AddMailboxPermission {
   param (
       [string]$Lid,
       [string]$Mailbox,
       [switch]$AutoMapping = $false
   )

   f-exocheck
   $Mailbox = Get-Mailbox -Identity $Mailbox
   remove-MailboxPermission -Identity $Mailbox -User $Lid -AccessRights FullAccess -ErrorAction SilentlyContinue -Confirm:$false
   Add-MailboxPermission -Identity $Mailbox -User $Lid -AccessRights FullAccess -AutoMapping $automapping
   Add-RecipientPermission -Identity $Mailbox -Trustee $Lid -AccessRights SendAs -Confirm:$false
}


 function f-localizemailbox
{
   f-exocheck
(get-mailbox).primarysmtpaddress | Set-MailboxRegionalConfiguration -Language 1043 -TimeZone "W. Europe Standard Time" -LocalizeDefaultFolderName
}

function f-resetww
{
$resetaddress = Read-Host "Voer het e-mailadres in waarvan je het wachtwoord wilt resetten"
$alias,$domein = $resetaddress.split("{@}")
$ww = Get-MsolPartnerContract -DomainName $domein | Set-MsolUserPassword -UserPrincipalName $resetaddress

Write-Host " "
Write-Host "Ik stuur deze e-mail omdat ik op verzoek het wachtwoord van $resetaddress heb gereset."
Write-Host " "
Write-host "Het nieuwe tijdelijke wachtwoord van $resetaddress is: $ww"
write-host "Graag met dit tijdelijke wachtwoord inloggen op https://portal.office.com om een nieuw eigen wachtwoord in te stellen."
Write-Host " "
Write-Host "Tip: Als de browser niet het inlogscherm opent, maar automatisch al inlogt op een account, open dan de browser in privémodus."
Write-Host "Voor instructie hierover, zie: https://www.yourhosting.nl/support/website/privemodus-browser/"
}

function f-getadmins {
Get-MsolRoleMember -RoleObjectId $(Get-MsolRole -RoleName "Company Administrator").ObjectId -TenantId $cid
}

function f-adddomain {
$adddomain = Read-Host "Welke domeinnaam wil je toevoegen?"
New-AzureADDomain -name $adddomain
sleep 5
$txtrecord = Get-AzureADDomainVerificationDnsRecord -name $adddomain
write-host $txtrecord.text
Read-Host "Druk op Enter, zodra je het txt-record met TTL 1 minuut hebt toegevoegd"
Confirm-AzureADDomain -Name $adddomain
sleep 5
Set-AzureADDomain -Name $adddomain -SupportedServices "Email"
sleep 5
Get-AzureADDomainServiceConfigurationRecord -Name $adddomain | ? {$_.RecordType -eq "Mx"} | select MailExchange
} 

function f-licenties {
Get-MsolAccountSku -TenantId $cid
}

function f-users {
Get-MsolUser -TenantId $cid | select-object userprincipalname,displayname,licenses
}

function f-getalias {
Get-Mailbox -ResultSize Unlimited | Select-Object DisplayName,@{Name=”EmailAddresses”;Expression={$_.EmailAddresses |Where-Object {$_ -LIKE “SMTP:*”}}}
}

function f-setadmin {
$setasadmin = Read-Host "Welke gebruiker wil je adminrechten geven"
Add-MsolRoleMember -RoleMemberEmailAddress $setasadmin -RoleName "company administrator" -TenantId $cid
}

function f-alias {
   f-exocheck
   $user = Read-Host "Aan welke gebruiker wil je een alias toevoegen"
$alias = Read-Host "Welke alias"
Set-Mailbox $user -EmailAddresses @{add="$alias"}
}

function f-getdistrubution {
# CSV file export path
$Csvfile = "C:\temp\ExportDGs.csv"

# Get all distribution groups
$Groups = Get-DistributionGroup -ResultSize Unlimited

# Loop through distribution groups
$Groups | ForEach-Object {

    $Group = $_.Name
    $DisplayName = $_.DisplayName
    $PrimarySmtpAddress = $_.PrimarySmtpAddress
    $SecondarySmtpAddress = $_.EmailAddresses | Where-Object {$_ -clike "smtp*"} | ForEach-Object {$_ -replace "smtp:",""}
    $GroupType = $_.GroupType
    $RecipientType = $_.RecipientType
    $Members = Get-DistributionGroupMember $group
    $ManagedBy = $_.ManagedBy
    $Alias = $_.Alias
    $HiddenFromAddressLists = $_.HiddenFromAddressListsEnabled
    $MemberJoinRestriction = $_.MemberJoinRestriction 
    $MemberDepartRestriction = $_.MemberDepartRestriction
    $RequireSenderAuthenticationEnabled = $_.RequireSenderAuthenticationEnabled
    $AcceptMessagesOnlyFrom = $_.AcceptMessagesOnlyFrom
    $GrantSendOnBehalfTo = $_.GrantSendOnBehalfTo

    # Create objects
    [PSCustomObject]@{
        Name                               = $Group
        DisplayName                        = $DisplayName
        PrimarySmtpAddress                 = $PrimarySmtpAddress
        SecondaryStmpAddress               = ($SecondarySmtpAddress -join ',')
        Alias                              = $Alias
        GroupType                          = $GroupType
        RecipientType                      = $RecipientType
        Members                            = ($Members.Name -join ',')
        MembersPrimarySmtpAddress          = ($Members.PrimarySmtpAddress -join ',')
        ManagedBy                          = $ManagedBy.Name
        HiddenFromAddressLists             = $HiddenFromAddressLists
        MemberJoinRestriction              = $MemberJoinRestriction 
        MemberDepartRestriction            = $MemberDepartRestriction
        RequireSenderAuthenticationEnabled = $RequireSenderAuthenticationEnabled
        AcceptMessagesOnlyFrom             = ($AcceptMessagesOnlyFrom.Name -join ',')
        GrantSendOnBehalfTo                = $GrantSendOnBehalfTo.Name
    }

# Export report to CSV file
} | Export-CSV -Path $Csvfile -NoTypeInformation -Encoding UTF8 #-Delimiter ";"
 Write-Output "Saved to" $Csvfile }

 function f-setautoreply {
 # clear screen #
cls

# set formatlist output to the given value
$FormatEnumerationLimit = $null

# Mailboxname to set OOO message #
[string] $mbname = Read-Host -prompt ‘Enter Mailbox to set OOO’

while ($mbname -notlike “*@*” -or $mbname -notlike “*.*”){

write-host -ForegroundColor yellow “Please provide a valid smtp address!”

[string] $mbname = Read-Host -prompt ‘Enter Mailbox to set OOO’

}

# OOO message #
Write-Host “”

[string] $message = Read-Host -Prompt ‘Paste OOO Message here – Leave blank if you plan to disable’

# Place OOO message inside HTML Tags to preserve formatting #
$oootxt = ‘<pre>’ + $message + ‘</pre>’

# Actions #
Write-Host “”

[string] $mode = Read-Host -Prompt ‘(e)nable (d)isable or (s)chedule’

# (e)nable #
if ($mode -match “e”) {

get-mailbox -Identity $mbname | Set-MailboxAutoReplyConfiguration -AutoReplyState Enabled -ExternalMessage $oootxt

}

# (d)isable
if ($mode -match “d”) {

get-mailbox -Identity $mbname | Set-MailboxAutoReplyConfiguration -AutoReplyState Disabled

}

# (s)schedule
if ($mode -match “s”) {


[string]$starttime = Read-Host -Prompt 'Enter Start-Time according to your system time. For example: 00:00:00 – Start-Time will be valid from 12/31/xxxx 00:01'

[string]$endtime = Read-Host -Prompt 'Enter End-Time according to your system time. For example: 00:00:00 – Start-Time will be valid from  01/28/xxxx 00:01'

get-mailbox -Identity $mbname | Set-MailboxAutoReplyConfiguration -AutoReplyState Scheduled -InternalMessage $oootxt -ExternalMessage $oootxt -StartTime $starttime -EndTime $endtime

}

# Display Results
Write-host “————————————————————————–”

Write-host -ForegroundColor green “The following OOO settings have been applied to mailbox:” $mbname

$a = get-mailbox -Identity $mbname | Get-MailboxAutoReplyConfiguration | select AutoReplyState, StartTime , Endtime, InternalMessage, ExternalMessage | fl

$a
}
function f-getazureapp {
[string] $appname = Read-Host -prompt ‘Enter Enterprise APP’
Get-AzureADApplication -Filter "DisplayName eq '$appname'"}

function f-getlogins{

[CmdletBinding(ConfirmImpact = 'None')]
param
(
   [Parameter(ValueFromPipeline,
      ValueFromPipelineByPropertyName)]
   [ValidateNotNull()]
   [ValidateNotNullOrEmpty()]
   [Alias('DaysToSearch')]
   [int]
   $Days = 30
)

begin
{
   #region
   if ($Days -lt 1)
   {
      Write-Error -Exception 'Value to low' -Message 'The given Days Value is below 1' -Category InvalidArgument -TargetObject $Days -RecommendedAction 'Select between 1 and 30' -ErrorAction Stop
      Exit 1
   }

   if ($Days -gt 30)
   {
      Write-Error -Exception 'Value to high' -Message 'The given Days Value is above 30' -Category InvalidArgument -TargetObject $Days -RecommendedAction 'Select between 1 and 30' -ErrorAction Stop
      Exit 1
   }
   $null = (Disconnect-AzureAD -Confirm:$false -ErrorAction SilentlyContinue)
   $null = (Remove-Module -Name AzureAD -Force -ErrorAction SilentlyContinue)
   $null = (Import-Module -Name AzureADPreview -Force -ErrorAction SilentlyContinue)
   $null = (Connect-AzureAD -AccountId $upn -TenantId $cid)

   # Garbage Collection
   [GC]::Collect()

   # Cleanup
   $filterAll = $null
   $AzureAdSignInAll = $null
   $AzureAdSignInFail = $null
   $AzureAdSignInGood = $null
   $AzureAdSignInAllCAfail = $null
   $AzureAdSignInFailCAfail = $null
   $AzureAdSignInGoodCAfail = $null

   # Define some defaults
   $StartDateRaw = ((Get-Date).addDays(-$Days))
   $StartDate = ('{0}-{1}-{2}' -f $StartDateRaw.Year, $StartDateRaw.Month, $StartDateRaw.Day)
   $StartDateRaw = $null
   $EndDateRaw = (Get-Date)
   $EndDate = ('{0}-{1}-{2}' -f $EndDateRaw.Year, $EndDateRaw.Month, $EndDateRaw.Day)
   $EndDateRaw = $null
}

process
{
   try
   {
      # Filtering
      $filterAll = ('createdDateTime ge {0} and createdDateTime le {1}' -f $StartDate, $EndDate)

      # Get the Logs
      $AzureAdSignInAll = (Get-AzureADAuditSignInLogs -Filter $filterAll)

      # Rest is done with filtering
      $AzureAdSignInFail = ($AzureAdSignInAll | Where-Object -FilterScript {
            $_.status.errorCode -ne 0
         })
      $AzureAdSignInGood = ($AzureAdSignInAll | Where-Object -FilterScript {
            $_.status.errorCode -eq 0
         })

      #region StructureData
      $AzureAdSignInGood = ($AzureAdSignInGood | Select-Object -Property CreatedDateTime, UserPrincipalName, RiskState, AppId, ClientAppUsed, IpAddress, @{
            N = 'City'
            E = {
               $_.Location.City
            }
         }, @{
            N = 'CountryOrRegion'
            E = {
               $_.Location.CountryOrRegion
            }
         }, @{
            N = 'FailureReason'
            E = {
               $_.Status.FailureReason
            }
         }, ConditionalAccessStatus)

      $AzureAdSignInAll = ($AzureAdSignInAll | Select-Object -Property CreatedDateTime, UserPrincipalName, RiskState, AppId, ClientAppUsed, IpAddress, @{
            N = 'City'
            E = {
               $_.Location.City
            }
         }, @{
            N = 'CountryOrRegion'
            E = {
               $_.Location.CountryOrRegion
            }
         }, @{
            N = 'FailureReason'
            E = {
               $_.Status.FailureReason
            }
         }, ConditionalAccessStatus)

      $AzureAdSignInFail = ($AzureAdSignInFail | Select-Object -Property CreatedDateTime, UserPrincipalName, RiskState, AppId, ClientAppUsed, IpAddress, @{
            N = 'City'
            E = {
               $_.Location.City
            }
         }, @{
            N = 'CountryOrRegion'
            E = {
               $_.Location.CountryOrRegion
            }
         }, @{
            N = 'FailureReason'
            E = {
               $_.Status.FailureReason
            }
         }, ConditionalAccessStatus)
      #endregion StructureData

      #region ConditionalAccessFilter
      # BUG: Does not work as expected
      $AzureAdSignInAllCAfail = ($AzureAdSignInAll | Where-Object -FilterScript {
            (($_.ConditionalAccessStatus -ne 'success') -and ($_.ConditionalAccessStatus -ne 'notApplied'))
         })

      $AzureAdSignInFailCAfail = ($AzureAdSignInFail | Where-Object -FilterScript {
            (($_.ConditionalAccessStatus -ne 'success') -and ($_.ConditionalAccessStatus -ne 'notApplied'))
         })

      $AzureAdSignInGoodCAfail = ($AzureAdSignInGood | Where-Object -FilterScript {
            (($_.ConditionalAccessStatus -ne 'success') -and ($_.ConditionalAccessStatus -ne 'notApplied'))
         })
      #endregion ConditionalAccessFilter

      $TimeStamp = Get-Date -Format yyyyMMdd_HHmmss

      # TODO: Make it a parameter
      $ExportPath = ('.\PowerShell\exports\AzureADSignInAudit')

      if (-not (Test-Path -Path $ExportPath))
      {
         $null = (New-Item -Path $ExportPath -ItemType Directory -Force)
      }

      #region Export
      $null = ($AzureAdSignInAll | Export-Csv -Path ($ExportPath + '\AllSignInAuditLogs_' + $TimeStamp + $domainname + '.csv') -NoTypeInformation -Force -Encoding UTF8)

      $null = ($AzureAdSignInFail | Export-Csv -Path ($ExportPath + '\FailSignInAuditLogs_' + $TimeStamp + $domainname + '.csv') -NoTypeInformation -Force -Encoding UTF8)

      $null = ($AzureAdSignInGood | Export-Csv -Path ($ExportPath + '\GoodSignInAuditLogs_' + $TimeStamp + $domainname + '.csv') -NoTypeInformation -Force -Encoding UTF8)

      if ($AzureAdSignInAllCAfail)
      {
         $null = ($AzureAdSignInAllCAfail | Export-Csv -Path ($ExportPath + '\AllSignInAuditLogs_CAFAIL_' + $TimeStamp + $domainname + '.csv') -NoTypeInformation -Force -Encoding UTF8)
      }

      if ($AzureAdSignInFailCAfail)
      {
         $null = ($AzureAdSignInFailCAfail | Export-Csv -Path ($ExportPath + '\FailSignInAuditLogs_CAFAIL_' + $TimeStamp + $domainname + '.csv') -NoTypeInformation -Force -Encoding UTF8)
      }

      if ($AzureAdSignInGoodCAfail)
      {
         $null = ($AzureAdSignInGoodCAfail | Export-Csv -Path ($ExportPath + '\GoodSignInAuditLogs_CAFAIL_' + $TimeStamp + $domainname + '.csv') -NoTypeInformation -Force -Encoding UTF8)
      }
      #endregion Export
   }
   catch
   {
      #region ErrorHandler
      # get error record
      [Management.Automation.ErrorRecord]$e = $_

      # retrieve information about runtime error
      $info = [PSCustomObject]@{
         Exception = $e.Exception.Message
         Reason    = $e.CategoryInfo.Reason
         Target    = $e.CategoryInfo.TargetName
         Script    = $e.InvocationInfo.ScriptName
         Line      = $e.InvocationInfo.ScriptLineNumber
         Column    = $e.InvocationInfo.OffsetInLine
      }

      # output information. Post-process collected info, and log info (optional)
      $info | Out-String | Write-Verbose

      $paramWriteError = @{
         Message      = $e.Exception.Message
         ErrorAction  = 'Stop'
         Exception    = $e.Exception
         TargetObject = $e.CategoryInfo.TargetName
      }
      Write-Error @paramWriteError

      # Only here to catch a global ErrorAction overwrite
      exit 1
      #endregion ErrorHandler
   }
   finally
   {
      # Cleanup
      $filterAll = $null
      $AzureAdSignInAll = $null
      $AzureAdSignInFail = $null
      $AzureAdSignInGood = $null
      $AzureAdSignInAllCAfail = $null
      $AzureAdSignInFailCAfail = $null
      $AzureAdSignInGoodCAfail = $null

      # Garbage Collection
      [GC]::Collect()
   }
}
}

function f-makeadmin {
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
 
function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}
 
$password = Get-RandomCharacters -length 13 -characters 'abcdefghiklmnoprstuvwxyz'
$password += Get-RandomCharacters -length 2 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
$password += Get-RandomCharacters -length 1 -characters '1234567890'
$password += Get-RandomCharacters -length 2 -characters '!"$%&/()=?}][{@#*+'
$password = Scramble-String $password

$MsolDomains = Get-MsolDomain -TenantId $cid

$regex = '^[^.]*\.onmicrosoft\.com$'
        $Domain = $MsolDomains |
            Where-Object Name -Match $regex |
            Select-Object -ExpandProperty Name |
            Select-Object -First 1

New-MsolUser -TenantId $cid -DisplayName "Easy Office Online - Beheeraccount" -UserPrincipalName eooadmin@$domain -FirstName EOO -LastName Admin -PasswordNeverExpires $true -Password $password -ForceChangePassword $false
Add-MsolRoleMember -RoleMemberEmailAddress "eooadmin@$domain" -RoleName "company administrator" -TenantId $cid
}

function f-eooasgroupowner {
   $name = Read-Host "Wat is de naam van de groep?"
   
   $groups = Get-MsolGroup -TenantId $cid
   $errorgroup = ($groups | Where-Object {$_.displayname -match $name}).ObjectId.guid

   $users = Get-MsolUser -TenantId $CID
   $eooadmin = ($users | Where-Object {$_.displayname -match "Easy Office Online - Beheeraccount"}).ObjectId.guid

   Connect-AzureAD -TenantId $cid -AccountId $upn
   Add-AzureADGroupOwner -ObjectId $errorgroup -RefObjectId $eooadmin
   }
function f-importloc {
   Set-Location $env:import
   }
   
function f-scriptsloc {
   Set-Location $env:ps
   }
   
function prompt {
    $p = Split-Path -leaf -path (Get-Location)
    "$p> "
   }

function f-wweoo {  
function Get-RandomCharacters($length, $characters) {
    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
    $private:ofs=""
    return [String]$characters[$random]
}
 
function Scramble-String([string]$inputString){     
    $characterArray = $inputString.ToCharArray()   
    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
    $outputString = -join $scrambledStringArray
    return $outputString 
}
 
$password = Get-RandomCharacters -length 4 -characters 'abcdefghiklmnoprstuvwxyz'
$password += Get-RandomCharacters -length 2 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
$password += Get-RandomCharacters -length 1 -characters '1234567890'
$password += Get-RandomCharacters -length 1 -characters '!"$%&/()=?}][{@#*+'
$password = Scramble-String $password

$MsolDomains = Get-MsolDomain -TenantId $cid

$regex = '^[^.]*\.onmicrosoft\.com$'
        $Domain = $MsolDomains |
            Where-Object Name -Match $regex |
            Select-Object -ExpandProperty Name |
            Select-Object -First 1


$eooadmin = "eooadmin@$domain"
$nwww = Set-MsolUserPassword -TenantId $cid -UserPrincipalName "eooadmin@$domain" -ForceChangePassword $false -NewPassword $password

write-host $eooadmin" | "$nwww
Set-Clipboard $nwww
}