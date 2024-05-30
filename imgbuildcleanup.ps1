#######################################################################################################################
###                                                                                                                 ###
###    Script Name: imgbuildcleanup.ps1                                                                             ###
###    Script Function: This script is designed to cleanup the C:\ImageBuild directory once the custom software     ###
###                     installs has completed. This makes sure that AVD OS disks are as small as possible.         ### 
###                                                                                                                 ###
###                                                                                                                 ###
###    Script Usage: This template script does not require any parameters at this time, but if required they can    ###
###                  be added and called as part of the custom image template process.                              ###
###                                                                                                                 ###        
###    Script Version: 1.0                                                                                          ###
###                                                                                                                 ###
#######################################################################################################################


# Set Log File Path
$LogFilePath = "C:\Windows\Temp\imgbuildcleanup.log"

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




# Delete all contents within C:\ImageBuild directory
try 
{
    Get-ChildItem -Path "C:\ImageBuild" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "Deleted all contents within C:\ImageBuild directory"
} 
catch 
{
    Write-Log "Failed to delete contents within C:\ImageBuild directory: $_.Exception.Message"
}

<#  Disconnect Z: drive
try {
    Remove-PSDrive -Name "Z" -ErrorAction Stop
    Write-Log "Disconnected Z: drive"
} catch {
    Write-Log "Failed to disconnect Z: drive: $_.Exception.Message"
}
 #>


### Try to unregister the Scheduled Task ###
Try
{
    Write-Log "Unregistering the scheduled task that called this script"
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
Write-Log "Script execution completed successfully!"
# End of script