#######################################################################################################################
###                                                                                                                 ###
###    Script Name: download.ps1                                                                                    ###
###    Script Function: This script is meant to download and extract contents of zip files from a Blob Storage      ###
###                     Account using AZCopy.exe that is downloaded and extracted in the azcopy.ps1 script.         ### 
###                     This script is used as part of the Custom Image Template deployments for AVD. Once all the  ###
###                     zip files have been downloaded from ther Blob Store the contents will then be extracted to  ###
###                     install software for the Custom Image build.                                                ### 
###                                                                                                                 ###
###                                                                                                                 ###
###    Script Usage: This script does not require any parameters at this time, but if required they can             ###
###                  be added and called as part of the custom image template process.                              ###
###                                                                                                                 ###        
###    Script Version: 1.0                                                                                          ###
###                                                                                                                 ###
#######################################################################################################################

# Set the Log File Path
$LogFilePath = "C:\ImageBuild\download.log"

# Function to write logs
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
    
    Write-Log "The application binary archive files have been found in the $Source directory"
    $destination = "C:\ImageBuild"
    Write-log "Copying application installation binaries from $source directory to the C:\ImageBuild directory"
    ### Update the <Archive Location> with the SAS token for the proper download of the app binaries ###
    c:\\ImageBuild\\azcopy.exe copy 'https://efa56cc125stg.blob.core.windows.net/microsoftapps?sp=rl&st=2024-05-16T16:08:09Z&se=2024-05-26T00:08:09Z&spr=https&sv=2022-11-02&sr=c&sig=8jh0Zzx2LEEPjIACPE4iTGkCbYq2gpQqwtlLEwPRu%2Bc%3D' 'c:\\ImageBuild\\' --recursive=true   
    Write-Log "Successfully copied all application installation binaries to the C:\ImageBuild directory."
    Write-Log "Finding the required application binary archives"
    # Get all folders in the specified directory
    #$folders = Get-ChildItem -Path "C:\ImageBuild" -Directory
    # Sort folders by creation time in descending order
    #$sortedFolders = $folders | Sort-Object CreationTime -Descending
    # Get the most recently created folder
    #$mostRecentFolder = $sortedFolders[0].Name
    $source = "C:\ImageBuild\" 
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
        #$zipFileName = [System.IO.Path]::GetFileNameWithoutExtension($zipFile.FullName)
        
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
