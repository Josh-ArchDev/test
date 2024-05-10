#######################################################################################################################
###                                                                                                                 ###
###    Script Name: imgbuildcleanup.ps1                                                                             ###
###    Script Function: This script is designed to cleanup the C:\ImageBuild directory once the custom software     ###
###                     installs has completed. This makes sure that AVD OS disks are as small as possible.         ### 
###                                                                                                                 ###
###                                                                                                                 ###
###    Script Usage: This template script does not require any parameters at this time, but if required they can    ###
###                  be added and called as part of the custom image template process.                              ###
###                                                                                                                 ###        
###    Script Version: 1.0                                                                                          ###
###                                                                                                                 ###
#######################################################################################################################

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



$LogFilePath = "C:\Windows\Temp\imgbuildcleanup.log"



# Delete all contents within C:\ImageBuild directory
try 
{
    Get-ChildItem -Path "C:\ImageBuild" | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    Write-Log "Deleted all contents within C:\ImageBuild directory"
} 
catch 
{
    Write-Log "Failed to delete contents within C:\ImageBuild directory: $_.Exception.Message"
}

<#  Disconnect Z: drive
try {
    Remove-PSDrive -Name "Z" -ErrorAction Stop
    Write-Log "Disconnected Z: drive"
} catch {
    Write-Log "Failed to disconnect Z: drive: $_.Exception.Message"
}
 #>

Write-Log "Script execution completed successfully!"
