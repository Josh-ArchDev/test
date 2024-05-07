$LogFilePath = "C:\ImageBuild\extractinstalls.log"


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

# Azure Image Builder Portal Integration Inline Commands
# Inline command that uses AZCopy to download the archive file and extract to the ImageBuilder directory
# Use the SAS URL for the <ArchiveSource>

# Directory where zip files are located
$source = "C:\ImageBuild"

# Destination directory where zip files will be extracted
$destination = "C:\ImageBuild"

# Get list of zip files in source directory
try {
    $zipFiles = Get-ChildItem -Path $source -Filter *.zip -ErrorAction Stop
} catch {
    HandleError "Failed to get list of zip files: $_.Exception.Message"
    exit 1
}

# Iterate through each zip file and extract its contents
foreach ($zipFile in $zipFiles) {
    try {
        # Get the name of the zip file without extension
        $zipFileName = [System.IO.Path]::GetFileNameWithoutExtension($zipFile.FullName)
        
        # Extract the contents of the zip file to the destination directory
        Expand-Archive -Path $zipFile.FullName -DestinationPath $destination -ErrorAction Stop
        
        # Log success message
        Write-Log "Extracted $($zipFile.Name) to $destination"
    } catch {
        # Log error message if extraction fails
        HandleError "Failed to extract $($zipFile.Name): $_.Exception.Message"
    }
}

Write-Host "Script execution completed successfully!"
Write-Log "Script execution completed successfully!"
