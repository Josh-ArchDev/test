$LogFilePath = "C:\ImageBuild\imgbuildcleanup.log"


# Function to log messages to console and file
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
        # Log message to console and file
        Write-Host $Message
        Add-Content -Path $LogFilePath -Value "$(Get-Date) - $Message"

    }
    catch
    {
        write-host "Having issues creating or adding information to the logfile at $LogFilePath"
    }
}



# Function to handle errors
function HandleError {
    param (
        [string]$ErrorMessage
    )
    Write-Host "Error: $ErrorMessage"
    Write-Log "Error: $ErrorMessage"
}

# Delete all contents within C:\ImageBuild directory
try {
    Get-ChildItem -Path "C:\ImageBuild" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "Deleted all contents within C:\ImageBuild directory"
} catch {
    HandleError "Failed to delete contents within C:\ImageBuild directory: $_"
}

# Disconnect Z: drive
try {
    Remove-PSDrive -Name "Z" -ErrorAction Stop
    Write-Log "Disconnected Z: drive"
} catch {
    HandleError "Failed to disconnect Z: drive: $_"
}

Write-Host "Script execution completed successfully!"
Write-Log "Script execution completed successfully!"
