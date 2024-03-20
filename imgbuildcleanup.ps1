# Function to log messages to a file
function LogMessage {
    param (
        [string]$Message
    )
    $LogFile = "C:\ImageBuild\imgbuildcleanup_log.txt"
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp - $Message"
    Add-content -Path $LogFile -Value $LogEntry
}

# Function to handle errors
function HandleError {
    param (
        [string]$ErrorMessage
    )
    Write-Host "Error: $ErrorMessage"
    LogMessage "Error: $ErrorMessage"
}

# Delete all contents within C:\ImageBuild directory
try {
    Get-ChildItem -Path "C:\ImageBuild" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    LogMessage "Deleted all contents within C:\ImageBuild directory"
} catch {
    HandleError "Failed to delete contents within C:\ImageBuild directory: $_"
}

# Disconnect Z: drive
try {
    Remove-PSDrive -Name "Z" -ErrorAction Stop
    LogMessage "Disconnected Z: drive"
} catch {
    HandleError "Failed to disconnect Z: drive: $_"
}

Write-Host "Script execution completed successfully!"
LogMessage "Script execution completed successfully!"
