$Mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox | Where-Object { $_.alias -ne "admin" }

$Mailboxes | Select-Object DisplayName, UserPrincipalName, RecipientTypeDetails | Export-Csv -Path "C:\temp\File.csv" -NoTypeInformation


# Specify the out-of-office message and start/end dates, Remove ---- message -------
$oomMessage = @"
<html>
<body>
<p>Beste,</p>
<br>
<p>Het volledige Arcade team geniet van een deugddoend bouwverlof. <br> Onze kantoren zijn volledig gesloten vanaf maandag 10 juli tot en met vrijdag 28 juli. <br> Op maandag 31 juli organiseren wij onze jaarlijkse “Arcade-dag”. Dinsdag 1 augustus staan wij opnieuw klaar om uw vragen te beantwoorden.</p>
<br>
<p>Zonnige groeten,</p>
</body>
</html>
"@
$startDate = Get-Date "2023-07-07 19:00:00"
$endDate = Get-Date "2023-07-31 19:00:00"


foreach ($mailbox in $Mailboxes){
    $identity = $mailbox.UserPrincipalName
    Set-MailboxAutoReplyConfiguration -Identity $identity -AutoReplyState Scheduled -StartTime $startDate -EndTime $endDate -ExternalMessage $oomMessage -InternalMessage $oomMessage
    Write-Host "Out-of-office message has been set for $identity in arcade-eng.com domain."
}

Write-Host "Out-of-office message has been set for all users in arcade-eng.com domain."