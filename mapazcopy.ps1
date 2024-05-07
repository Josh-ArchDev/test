$LogFilePath = "C:\ImageBuild\mapazcopy.log"


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
        write-host "Having issues creating or adding information to the logfile at $LogFilePath $_.Exception.Message"
        Exit 1
    }
}



# Function to handle errors
function HandleError {
    param (
        [string]$ErrorMessage
    )
    Write-Host "Error: $ErrorMessage"
    Write-Log "Error: $ErrorMessage"
    exit 1
}

# Check if ImageBuild directory exists, if not, create it
if (-not (Test-Path -Path "C:\ImageBuild")) {
    try {
        New-Item -Path "C:\ImageBuild" -ItemType Directory -ErrorAction Stop
        Write-Log "Created C:\ImageBuild directory"
    } catch {
        HandleError "Failed to create C:\ImageBuild directory"
        Exit 1
    }
}

# Map network drive to \\10.229.208.24\img-build as Z: drive
try {
    New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\10.229.208.24\img-build" -ErrorAction Stop | Out-Null
    Write-Log "Mapped network drive to Z: drive"
} catch {
    HandleError "Failed to map network drive $_.Exception.Message"
    Exit 2
}

# Copy contents of network share to C:\ImageBuild directory

try {
    Copy-Item -Path "Z:\genpactapps\*" -Destination "C:\ImageBuild" -Recurse -ErrorAction Stop
    Write-Log "Copied contents from network share to C:\ImageBuild"
} catch {
    HandleError "Failed to copy contents from network share to C:\ImageBuild $_.Exception.Message"
    Exit 3
}

Write-Host "Script execution completed successfully!"
Write-Log "Script execution completed successfully!"
