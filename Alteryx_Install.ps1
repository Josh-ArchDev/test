#######################################################################################################################
###                                                                                                                 ###
###    Script Name: Alteryx_Install.ps1                                                                             ###
###    Script Function: This script is meant to be run within a Custom Image Template deployment within Azure       ###
###                     Virtual Desktop. This script installs the Alteryx software for the Genpact EN/MX Use case   ###
###                     within Walmart.                                                                             ### 
###                     from Azure Blob Storage.                                                                    ###
###                                                                                                                 ###
###    Script Usage: This template script does not require any parameters at this time, but if required they can    ###
###                  be added and called as part of the custom image template process.                              ###
###                                                                                                                 ###        
###    Script Version: 1.0                                                                                          ###
###                                                                                                                 ###
#######################################################################################################################

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine
S


$LogFilePath = "C:\ImageBuild\Alteryx_Install.log"
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
#Alteryx

try 
{
	Write-Log "Starting the install of the Alteryx Package"
	Start-Process -FilePath "C:\ImageBuild\Alteryx_64bit_ver[2019.4g]\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
	Write-Log "Successfully Completed the install of the Alteryx Package"

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Alteryx_2019.4g: $ErrorMessage"
	Exit 42
}
