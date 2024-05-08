# Azure Image Builder Portal Integration Inline Commands
# Inline command that uses AZCopy to download the archive file and extract to the ImageBuilder directory
# Use the SAS URL for the <ArchiveSource>

Function Write-Log
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



### Try to copy all zip files in the blob storage container ###
try 
{
    
    Write-Log "Finding the required application binary archives"
    # Get all folders in the specified directory
    $folders = Get-ChildItem -Path "C:\ImageBuild" -Directory
    # Sort folders by creation time in descending order
    $sortedFolders = $folders | Sort-Object CreationTime -Descending
    # Get the most recently created folder
    $mostRecentFolder = $sortedFolders[0].Name
    $source = "C:\ImageBuild" + $mostRecentFolder
    Write-Log "The application binary archive files have been found in the $Source directory"
    $destination = "C:\ImageBuild"
    Write-log "Copying application installation binaries from $source directory to the C:\ImageBuild directory"
    c:\\ImageBuild\\azcopy.exe copy 'https://efa56cc125stg.blob.core.windows.net/genpactapps?sp=rl&st=2024-05-08T16:40:15Z&se=2024-05-16T00:40:15Z&spr=https&sv=2022-11-02&sr=c&sig=6tjv81sxmT%2Be417xVLZjTMprSrAKdFd9rjOKCah3v8M%3D' 'c:\\ImageBuild\\' --recursive=true   
    Write-Log "Successfully copied all application installation binaries to the C:\ImageBuild directory."
}
catch 
{
    Write-Log -Message "An error occurred: $($_.Exception.Message)"
    Exit 1
}

# Get list of zip files in source directory
try {
    $zipFiles = Get-ChildItem -Path $source -Filter *.zip -ErrorAction Stop
} catch {
    Write-Log "Failed to get list of zip files: $_"
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
        Write-Log "Failed to extract $($zipFile.Name): $_.exception.message"
    }
}


Write-Log "Script execution completed successfully!"
