$content = @' 
@
# Clear C:\Windows\Temp
Remove-Item -Path "C:\Windows\Temp\*" -Force -Recurse

# Clear C:\Windows\Prefetch
Remove-Item -Path "C:\Windows\Prefetch\*" -Force -Recurse

# Clear C:\Documents and Settings\*\Local Settings\temp
$profiles = Get-ChildItem -Path "C:\Documents and Settings\" -Directory -Force
foreach ($profile in $profiles) {
    $tempPath = Join-Path -Path $profile.FullName -ChildPath "Local Settings\Temp\*"
    Remove-Item -Path $tempPath -Force -Recurse
}

# Clear C:\Users\*\Appdata\Local\Temp
$profiles = Get-ChildItem -Path "C:\Users\" -Directory -Force
foreach ($profile in $profiles) {
    $tempPath = Join-Path -Path $profile.FullName -ChildPath "AppData\Local\Temp\*"
    Remove-Item -Path $tempPath -Force -Recurse
}
'@ 
 
 # create custom folder and write PS script 
$path = $(Join-Path $env:ProgramData First) 
if (!(Test-Path $path)) 
{ 
New-Item -Path $path -ItemType Directory -Force -Confirm:$false 
} 
Out-File -FilePath $(Join-Path $env:ProgramData First\Remove-temp.ps1) -Encoding unicode -Force -InputObject $content -Confirm:$false 
  
# register script as scheduled task 
$Time = New-ScheduledTaskTrigger -AtLogOn 
$User = "SYSTEM" 
$Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-ex bypass -file `"C:\ProgramData\First\Remove-temp.ps1`"" 
Register-ScheduledTask -TaskName "Remove Temp Folders" -Trigger $Time -User $User -Action $Action -Force 