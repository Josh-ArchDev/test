# Create a trigger that starts the task at system startup
$Trigger = New-ScheduledTaskTrigger -AtStartup
$STSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -StartWhenAvailable -Hidden -Compatibility Win8

# Create an action that specifies calling powershell.exe with parameters to run your script
$PSArgs = "-NoProfile -ExecutionPolicy Bypass -File"
$ScriptPath = "C:\Windows\Temp\MoveFSLogixRules.ps1"
$ScriptArgs = "$PSArgs" + " " + "$ScriptPath" 
$Action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "$ScriptArgs"

# Create the principal to run the task as Local System with highest privileges
$Principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -RunLevel Highest

# Register the task with the settings defined above
Register-ScheduledTask -TaskName "MoveFSLogixRules" -Trigger $Trigger -Action $Action -Principal $Principal -Settings $STSettings

# Output to indicate task creation
Write-Output "Scheduled task 'MoveFSLogixRules' created successfully."
