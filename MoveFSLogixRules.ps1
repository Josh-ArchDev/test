############################################################################################
### PowerShell script to move FSLogix Application Masking rules from a temp directory to ###
### the proper location. This is being done to avoid problems with the generalization of ###
### our AVD templates.                                                                   ###
###                                                                                      ###
############################################################################################

# Logifle Path
$LogFilePath = "C:\Windows\Temp\MoveFSLogixRules.log"
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


# Define source and destination directories
$sourcePath = "c:\Program Files\FSLogix\Apps\Rules\rules"
$destinationPath = "c:\Program Files\FSLogix\Apps\Rules"

# Check if the source directory exists
Try
{
    Write-Log "Moving the FSLogix Rules to the proper directory"
    if (Test-Path $sourcePath) {
        # Get all files in the source directory
        $files = Get-ChildItem -Path $sourcePath
    
        # Move each file to the destination directory
        foreach ($file in $files) {
            # Define the full destination path for the file
            $destinationFilePath = Join-Path -Path $destinationPath -ChildPath $file.Name
    
            # Move the file to the destination directory
            Move-Item -Path $file.FullName -Destination $destinationFilePath
        }
    
        # Output completion message
        Write-Log "All files have been moved from $sourcePath to $destinationPath."
    } else {
        # Output error message if the source directory does not exist
       Write-Log "The source directory $sourcePath does not exist."
    }
    
}
Catch
{
    $ErrorMessage = $_.Exception.message
    write-log "Error Copying the FSLogix Rules Files: $ErrorMessage"
	Exit 100

}

### Try to unregister the Scheduled Task ###
Try
{
    Write-Log "Unregistering the scheduled task that called this script"
    Unregister-ScheduledTask -TaskName "MoveFSLogixRules" -Confirm:$false
    Write-Log "Successfully unregistered the MoveFSLogixRules Scheduled Task"

}
Catch
{
    $ErrorMessage = $_.Exception.Message
    Write-Log "Error unregistering the Scheduled Task: $ErrorMessage"
    Write-Log "This error is non critical and the process will continue"
    Exit 0
}

# End of script
 