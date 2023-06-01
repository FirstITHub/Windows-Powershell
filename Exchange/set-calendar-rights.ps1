#get domain
$defaultdomain = (Get-MsolDomain -TenantId $cid | Where-Object isdefault -eq 'true').name

#get user creds
Write-Host "Je krijgt nu vragen over welke gebruiker (ALLEEN DE SHORT USERNAME) [EXAMPLE Sjoerd.Kanon] de rechten mag hebben"
$user = Read-Host "Welke gebruiker krijgt de agenda rechten"
$userrights = Read-Host "Welke agenda krijgt de user rechten"
Write-Host "De rechten die je kan geven zijn:
- FullAccess: Grants full access to the calendar, allowing the user to read, create, modify, and delete calendar items.
- Editor: Provides the ability to read, create, modify, and delete calendar items.
- Author: Allows the user to create and modify calendar items but not delete them.
- Reviewer: Grants read-only access to calendar items.
- Contributor: Enables the user to create calendar items but not modify or delete them.
- AvailabilityOnly: Provides access to free/busy information but not the details of calendar items.
- LimitedDetails: Allows access to calendar items with limited details.

Feel free to adjust the access rights according to your specific requirements when granting calendar permissions."
$Rights = Read-Host "Welke rechten geef je aan de gebruiker?"

#voeg gegevens samen
$usergetrights = $user+"@"+$defaultdomain
$rightsgetuser = $userrights
$mbox = $rightsgetuser+"@"+$defaultdomain+":\Agenda"
$mboxcal = $rightsgetuser+"@"+$defaultdomain+":\Calendar"
#Voer het script uit
Write-Host "M365 gaat nu voor je aan de slag"
Add-MailboxFolderPermission -Identity $mbox -User $usergetrights -AccessRights $Rights
Add-MailboxFolderPermission -Identity $mboxcal -User $usergetrights -AccessRights $Rights
Get-MailboxFolderPermission -Identity $mbox
Get-MailboxFolderPermission -Identity $mboxcal