#######################################################################################################################
###                                                                                                                 ###
###    Script Name: MDE_CreateScheduledTask.ps1                                                                     ###
###    Script Function: This script is meant to create a scheduled task that moves FSLogix rules to the proper      ###
###                     location. The script is required as FSlogix rules break sysprep                             ###
###                                                                                                                 ###
###    Script Usage: This template script does not require any parameters at this time, but if required they can    ###
###                  be added and called as part of the custom image template process.                              ###
###                                                                                                                 ###        
###    Script Version: 1.0                                                                                          ###
###                                                                                                                 ###
#######################################################################################################################
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine


# Logifle Path
$LogFilePath = "C:\ImageBuild\MDE_CreateScheduledTask.log"
# Function to write logs
function Write-Log
{
	param (
		[string]$Message
	)

	try
	{
		# Check if the log file directory exists, create it if not
		$logDirectory = Split-Path -Path $LogFilePath
		if (-Not (Test-Path -Path $logDirectory))
		{
			New-Item -Path $logDirectory -ItemType Directory
			Write-Host "Log directory created at: $logDirectory"
		}
		# Get current date and time
		$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
		# Log message with date and time to console and file
		$logMessage = "$dateTime - $Message"
		Write-Host $logMessage
		Add-Content -Path $LogFilePath -Value $logMessage
	}
	catch
	{
		write-host "Having issues creating or adding information to the logfile at $LogFilePath"
	}
}

#Copy MDE Onboarding file to C:\Windows\Temp
try 
{
    $OnboardingscriptsourcePath = "C:\ImageBuild\UtilityScripts\WindowsDefenderATPLocalOnboardingScript.cmd"
	$OnboardingscriptdestinationPath = "C:\Windows\Temp\WindowsDefenderATPLocalOnboardingScript.cmd"
	$STRemovalScriptPath = "C:\ImageBuild\UtilityScripts\Remove-MDEOnboardingST.ps1"
	$STScript = "C:\ImageBuild\UtilityScripts\MDE-OnboardingSTScript.ps1"
	Write-Log "Starting the copy of the WindowsDefenderATPLocalOnboardingScript.cmd file"
	if (Test-Path -Path $OnboardingscriptsourcePath) 
	{
		# Copy the file to the destination
		Copy-Item -Path $OnboardingscriptsourcePath -Destination $OnboardingscriptdestinationPath
		Write-Log "The WindowsDefenderATPLocalOnboardingScript.cmd File copied successfully."
	}
	Write-Log "Starting the copy of the Remove-MDEOnboardingST.ps1 file"
	if (Test-Path -Path $STRemovalScriptPath) 
	{
		# Copy the file to the destination
		Copy-Item -Path $STRemovalScriptPath -Destination "C:\Windows\Temp\Remove-MDEOnboardingST.ps1"
		Write-Log "The Remove-MDEOnboardingST.ps1 File copied successfully."
	}
	Write-Log "Starting copy of MDE-OnboardingSTScript.ps1 file to C:\Windows\Temp directory."
	if (Test-Path -Path $STScript) 
	{
		# Copy the file to the destination
		Copy-Item -Path $STScript -Destination "C:\Windows\Temp\MDE-OnboardingSTScript.ps1"
		Write-Log "The MDE-OnboardingSTScript.ps1 File copied successfully."
	}

    Write-Log "Starting the creation of the OnboardMDE Scheduled Task."
	# Create a trigger that starts the task at system startup
	$Trigger = New-ScheduledTaskTrigger -AtStartup
	$STSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -DontStopOnIdleEnd -StartWhenAvailable -Hidden -Compatibility Win8

	# Create an action that specifies calling powershell.exe with parameters to run your script
	$PSArgs = "-NoProfile -ExecutionPolicy Bypass -File"
	$ScriptPath = "C:\Windows\Temp\MDE-OnboardingSTScript.ps1"
	$ScriptArgs = "$PSArgs" + " " + "$ScriptPath" 
	$Action = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument "$ScriptArgs" -WorkingDirectory "C:\Windows\Temp"

	
	
	# Create the principal to run the task as Local System with highest privileges
	$Principal = New-ScheduledTaskPrincipal -UserId "NT AUTHORITY\SYSTEM" -RunLevel Highest

	# Register the task with the settings defined above
	Register-ScheduledTask -TaskName "OnboardMDE" -Trigger $Trigger -Action $Action -Principal $Principal -Settings $STSettings

	# Output to indicate task creation
	Write-Log "Scheduled task 'OnBoardMDE' created successfully."

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error creating the OnboardMDE Scheduled Task: $ErrorMessage"
    Exit 42
}