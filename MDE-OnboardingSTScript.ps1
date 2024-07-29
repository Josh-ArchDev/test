#######################################################################################################################
###                                                                                                                 ###
###    Script Name: MDE-OnboardingSTScript.ps1                                                                      ###
###    Script Function: This script is meant to as a scheduled task to execute the MDE onboarding script once a     ###
###                     machine joins the AD Domain.                                                                ###
###                                                                                                                 ###
###    Script Usage: This template script does not require any parameters at this time, but if required they can    ###
###                  be added and called as part of the custom image template process.                              ###
###                                                                                                                 ###        
###    Script Version: 1.0                                                                                          ###
###                                                                                                                 ###
#######################################################################################################################
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope LocalMachine


# Define the log file path
$LogFilePath = "C:\\Windows\\Temp\\MDE-OnboardingSTScript.log"

# Write-Log function definition
function Write-Log {
    param (
        [string]$Message
    )

    try {
        # Check if the log file directory exists, create it if not
        $logDirectory = Split-Path -Path $LogFilePath
        if (-Not (Test-Path -Path $logDirectory)) {
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
    catch {
        write-host "Having issues creating or adding information to the logfile at $LogFilePath"
    }
}

# Main script execution
try 
{
    # Get the domain of the current machine
    $currentDomain = (Get-WmiObject Win32_ComputerSystem).Domain

    # Check if the machine is part of the homeoffice.wal-mart.com domain
    if ($currentDomain -eq "homeoffice.wal-mart.com") 
    {
        Write-Log "The machine is part of the homeoffice.wal-mart.com domain."
        # Run the batch file if the machine is in the domain
        Write-Log "Running the batch file: C:\Windows\Temp\WindowsDefenderATPLocalOnboardingScript.cmd"
        Start-Process "C:\Windows\Temp\WindowsDefenderATPLocalOnboardingScript.cmd" -WorkingDirectory "C:\Windows\Temp" -Wait 
        Write-Log "Batch file executed successfully."
    } 
    else 
    {
        Write-Log "The machine is not part of the homeoffice.wal-mart.com domain. Exiting script."
        exit 0
    }
}
catch {
    Write-Log "An error occurred: $_"
    exit 1
}
