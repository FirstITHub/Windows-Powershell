$content = @' 
@(“C:\Windows\Temp\*”, “C:\Windows\Prefetch\*”, “C:\Documents and Settings\*\Local Settings\temp\*”, “C:\Users\*\Appdata\Local\Temp\*”)
Remove-Item $tempfolders -force -recurse
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