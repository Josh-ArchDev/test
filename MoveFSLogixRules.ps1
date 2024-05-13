############################################################################################
### PowerShell script to move FSLogix Application Masking rules from a temp directory to ###
### the proper location. This is being done to avoid problems with the generalization of ###
### our AVD templates.                                                                   ###
###                                                                                      ###
############################################################################################
# Define source and destination directories
$sourcePath = "c:\Program Files\FSLogix\Apps\Rules\rules"
$destinationPath = "c:\Program Files\FSLogix\Apps\Rules"

# Check if the source directory exists
if (Test-Path $sourcePath) {
    # Get all files in the source directory
    $files = Get-ChildItem -Path $sourcePath

    # Move each file to the destination directory
    foreach ($file in $files) {
        # Define the full destination path for the file
        $destinationFilePath = Join-Path -Path $destinationPath -ChildPath $file.Name

        # Move the file to the destination directory
        Move-Item -Path $file.FullName -Destination $destinationFilePath
    }

    # Output completion message
    Write-Host "All files have been moved from $sourcePath to $destinationPath."
} else {
    # Output error message if the source directory does not exist
    Write-Host "The source directory $sourcePath does not exist."
}

# End of script
 