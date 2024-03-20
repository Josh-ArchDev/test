# Function to log messages to a file
function LogMessage {
    param (
        [string]$Message
    )
    $LogFile = "C:\ImageBuild\mapazcopy_log.txt"
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
    exit 1
}

# Check if ImageBuild directory exists, if not, create it
if (-not (Test-Path -Path "C:\ImageBuild")) {
    try {
        New-Item -Path "C:\ImageBuild" -ItemType Directory -ErrorAction Stop
        LogMessage "Created C:\ImageBuild directory"
    } catch {
        HandleError "Failed to create C:\ImageBuild directory"
    }
}

# Map network drive to \\10.229.208.24\img-build as Z: drive
try {
    New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\10.229.208.24\img-build" -ErrorAction Stop | Out-Null
    LogMessage "Mapped network drive to Z: drive"
} catch {
    HandleError "Failed to map network drive"
}

# Copy contents of network share to C:\ImageBuild directory

try {
    Copy-Item -Path "Z:\genpactapps\*" -Destination "C:\ImageBuild" -Recurse -ErrorAction Stop
    LogMessage "Copied contents from network share to C:\ImageBuild"
} catch {
    HandleError "Failed to copy contents from network share to C:\ImageBuild"
}

Write-Host "Script execution completed successfully!"
LogMessage "Script execution completed successfully!"
