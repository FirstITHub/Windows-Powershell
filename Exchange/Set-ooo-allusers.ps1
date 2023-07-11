$domain = Get-AcceptedDomain | Where-Object { $_.Default -eq $true }
$usertoexclude = Read-Host "Welke Alias niet"
$Mailboxes = Get-Mailbox -ResultSize Unlimited -RecipientTypeDetails UserMailbox | Where-Object { $_.alias -ne $usertoexclude }

$Mailboxes | Select-Object DisplayName, UserPrincipalName, RecipientTypeDetails | Export-Csv -Path "C:\temp\File.csv" -NoTypeInformation


# Specify the out-of-office message and start/end dates, Remove ---- message -------
$oomMessage = @"
<html>
<body>
---header line----
<p></p>
---end of header line----
<br>
---body------
<p></p>
<br>
----end body -----
----signature-----
<p>Zonnige groeten,</p>
---- end signature -----
</body>
</html>
"@
$startDate = Get-Date "2023-07-07 19:00:00"
$endDate = Get-Date "2023-07-31 19:00:00"


foreach ($mailbox in $Mailboxes){
    $identity = $mailbox.UserPrincipalName
    Set-MailboxAutoReplyConfiguration -Identity $identity -AutoReplyState Scheduled -StartTime $startDate -EndTime $endDate -ExternalMessage $oomMessage
    Write-Host "Out-of-office message has been set for $identity in $domain."
}

Write-Host "Out-of-office message has been set for all users in $domain."