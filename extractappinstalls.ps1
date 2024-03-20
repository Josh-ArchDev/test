# Function to log messages to a file
function LogMessage {
    param (
        [string]$Message
    )
    $LogFile = "C:\ImageBuild\extractappinstalls_log.txt"
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
    HandleError "Failed to get list of zip files: $_"
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
        LogMessage "Extracted $($zipFile.Name) to $destination"
    } catch {
        # Log error message if extraction fails
        HandleError "Failed to extract $($zipFile.Name): $_"
    }
}

Write-Host "Script execution completed successfully!"
LogMessage "Script execution completed successfully!"
