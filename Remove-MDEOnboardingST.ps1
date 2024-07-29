#######################################################################################################################
###                                                                                                                 ###
###    Script Name: Remove-MDEOnboardingST.ps1                                                                      ###
###    Script Function: This script is meant to be run from C:\Windows\Temp and it will delete the MDEOnboarding    ###
###                     Scheduled Task once the scheduled task runs at the first system startup.                    ###
###                                                                                                                 ###
###    Script Usage: This template script does not require any parameters at this time, but if required they can    ###
###                  be added and called as part of the custom image template process.                              ###
###                                                                                                                 ###        
###    Script Version: 1.0                                                                                          ###
###                                                                                                                 ###
#######################################################################################################################

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine



# Set logging 
 
$LogFilePath = "C:\Windows\Temp\Remove-MDEOnboardingST.log"
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

### Try to unregister the Scheduled Task ###
Try
{
    Write-Log "Unregistering the OnboardMDE scheduled task"
    Unregister-ScheduledTask -TaskName "OnboardMDE" -Confirm:$false
    Write-Log "Successfully unregistered the OnboardMDE Scheduled Task"

}
Catch
{
    $ErrorMessage = $_.Exception.Message
    Write-Log "Error unregistering the Scheduled Task: $ErrorMessage"
    Write-Log "This error is non critical and the process will continue"
    Exit 0
}

# End of script
 