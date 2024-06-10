#######################################################################################################################
###                                                                                                                 ###
###    Script Name: ccappinstalls.ps1                                                                               ###
###    Script Function: This script is meant to be run within a Custom Image Template deployment within Azure       ###
###                     Virtual Desktop. This script installs the required software for the Genpact EN Use case     ###
###                     within Walmart.                                                                             ### 
###                     from Azure Blob Storage.                                                                    ###
###                                                                                                                 ###
###    Script Usage: This template script does not require any parameters at this time, but if required they can    ###
###                  be added and called as part of the custom image template process.                              ###
###                                                                                                                 ###        
###    Script Version: 1.0                                                                                          ###
###                                                                                                                 ###
#######################################################################################################################




# Set logging 
 
$LogFilePath = "C:\ImageBuild\ccappinstalls.log"
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
		# Get current date and time
		$dateTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
		# Log message with date and time to console and file
		$logMessage = "$dateTime - $Message"
		Write-Host $logMessage
		Add-Content -Path $LogFilePath -Value $logMessage
	}
	catch
	{
		write-host "Having issues creating or adding information to the logfile at $LogFilePath"
	}
}

#ForcePoint

try 
{
 
    Write-Log "Starting the ForcePoint Install"
	Start-Process -filepath 'C:\ImageBuild\FP-22.06\FORCEPOINT-ONE-ENDPOINT-x64.exe' -ArgumentList '/v" /quiet /norestart"' -Wait -ErrorAction Stop
	Write-Log "Successfully installed the ForcePoint Software"
    #Start-Sleep -Seconds 300
}
 
catch 
{
 
    $ErrorMessage = $_.Exception.message
    write-log "Error installing ForcePoint-v22.06.5578: $ErrorMessage"
	Exit 42
}

#Tanium

try 
{
	Write-Log "Starting the Tanium Install"    
	$source = "C:\ImageBuild\Tanium 7.4.7.1179\tanium-init.dat"
    Start-Process -FilePath 'C:\ImageBuild\Tanium 7.4.7.1179\TaniumInstall.cmd' -Wait -PassThru -ErrorAction Stop
    Start-Process -FilePath 'C:\Program Files (x86)\Tanium\Tanium Client\TaniumClient.exe' -ArgumentList "config remove ComputerID" -Wait -ErrorAction Stop
    Start-Process -FilePath 'C:\Program Files (x86)\Tanium\Tanium Client\TaniumClient.exe' -ArgumentList "config remove RegistrationCount" -Wait -ErrorAction Stop
    Start-Process -FilePath 'C:\Program Files (x86)\Tanium\Tanium Client\TaniumClient.exe' -ArgumentList "config remove LastGoodServerName" -Wait -ErrorAction Stop
    #Remove-Item -Path 'C:\Program Files (x86)\Tanium\Tanium Client\Downloads' -Recurse -Force
    #Remove-Item -Path 'C:\Program Files (x86)\Tanium\Tanium Client\Logs' -Recurse -Force
    Remove-Item -Path 'C:\Program Files (x86)\Tanium\Tanium Client\Backup' -Recurse -Force
    Stop-Service 'Tanium Client'
    Remove-Item -Path 'C:\Program Files (x86)\Tanium\Tanium Client\pki.db' -Force
    Copy-Item -Path $source -Destination 'C:\Program Files (x86)\Tanium\Tanium Client' 
	Write-Log "Successfully Completed the Tanium Software Install"   

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing ForcePoint-v22.06.5578: $ErrorMessage"
	Exit 42
}

#Trellix Proxy Agent

try 
{
	Write-Log "Starting the Trellix Proxy Agent Install"	
	Start-Process -FilePath "C:\ImageBuild\FramePkg581L.exe" -ArgumentList "/install=agent /silent" -Wait -ErrorAction Stop
	Write-Log "Successfully Completed the Trellix Proxy Agent Install"

}

catch 
{
	$ErrorMessage = $_.Exception.message
  	write-log "Error installing TrellixProxyAgent: $ErrorMessage"
	Exit 42
}

#Frameworks

try 
{
	Write-Log "Starting the install of Visual C++ Redist x64 Package"
	Start-Process -FilePath "c:\ImageBuild\Frameworks\VC_redist.x64.exe" -ArgumentList "/quiet /norestart" -Wait -ErrorAction Stop
	Write-Log "Successfully Completed the install of Visual C++ Redist x64 Package"
}
catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing VC_redist.x64.exe: $ErrorMessage"
	Exit 42
}

try 
{
	Write-Log "Starting the install of Visual C++ Redist x86 Package"	
	Start-Process -FilePath "c:\ImageBuild\Frameworks\VC_redist.x86.exe" -ArgumentList "/quiet /norestart" -Wait -ErrorAction Stop
	Write-Log "Successfully Completed the install of Visual C++ Redist x64 Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing VC_redist.x86.exe: $ErrorMessage"
	Exit 42
}

try 
{
	Write-Log "Starting the install of the .Net 3.5 Package"	
	Add-WindowsCapability -Online -Name NetFx3 -Source "C:\ImageBuild\Frameworks\dotnetfx35.exe"
	Write-Log "Successfully Completed the install of the .Net 3.5 Package"	
}
catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing dotnetfx35: $ErrorMessage"
	Exit 42
}

#NewTeams
<# 
try 
{
    Write-Log "Starting the install of the New Teams Client Package"	
	Start-Process -filepath 'C:\ImageBuild\Microsoft_Teams_ver24004.1309.2689.2246\Deploy-Application.exe' -ArgumentList 'Install NonInteractive' -Wait -ErrorAction Stop
    #Start-Sleep -Seconds 300
	Write-Log "Successfully Completed the install of the New Teams Client Package"
}
 
catch 
{
    $ErrorMessage = $_.Exception.message
    write-log "Error installing NewTeams: $ErrorMessage"
	Exit 42
}
 #>
#Reflection MultiHost

try 
{
	Write-Log "Starting the install of the Reflection MultiHost Package"
	Start-Process -FilePath "C:\ImageBuild\Reflection\Reflection_Multi_Host.EXE" -ArgumentList "/S /NOREBOOT" -Wait -ErrorAction Stop
	Write-Log "Successfully Completed the install of the Reflection MultiHost Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing ReflectionMultiHost: $ErrorMessage"
	Exit 42
}

#Chrome

try 
{
    Write-Log "Starting the install of the .Net 5.0 Package"
    Start-Process msiexec.exe -ArgumentList '/i c:\imagebuild\Chrome\googlechromestandaloneenterprise64.msi /qn' -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the .Net 5.0 Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Chromev120: $ErrorMessage"
    Exit 42
}
#ZoomVDI_5.16.24420

try 
{
    
    Write-Log "Starting the install of the Zoom VDI Package"
    Start-Process -FilePath "C:\ImageBuild\ZoomVDI_ver5.16.24420\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Zoom VDI Package"

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing ZoomVDI_5.16.24420: $ErrorMessage"
    Exit 42
}
	
#RightNowService

try 
{
	Write-Log "Starting the install of the Right Now Service Package"
	Start-Process -FilePath "C:\ImageBuild\RightNowService\RightNowService.EXE" -ArgumentList "/S /NOREBOOT" -ErrorAction Stop
	$folderPath = "C:\Windows\PackageLogs\RightNowService"
	$fileType = "*.wmt"
	$processName = "SHUTDO~1"
	while ($true) {
   		if (Test-Path $folderPath) {
       		$files = Get-ChildItem $folderPath -Filter $fileType
       		if ($files.Count -gt 0) {
           		#Write-Output "Found $($files.Count) $fileType files in $folderPath"
				Start-Sleep -Seconds 10
           		Stop-Process -Name $processName -Force
           		#Write-Output "$processName process has been stopped"
           	break
       	} else {
           	#Write-Output "No $fileType files found in $folderPath"
    }
  	} else {
       	#Write-Output "$folderPath does not exist"
}
   		Start-Sleep -Seconds 5
		Write-Log "Successfully Completed the install of the Right Now Service Package"
}	

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing RightNowService: $ErrorMessage"
	Exit 42
}


#AKA65_ver5.9k

try 
{
    Write-Log "Starting the install of the AKA65_ver 5.9k Package"
	Start-Process -FilePath "C:\ImageBuild\AKA65_ver5.9k\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Right Now Service Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing AKA65_ver5.9k: $ErrorMessage"
    Exit 42
}

#CitrixWorkspace - installation does not end on its own

try 
{
    Write-Log "Starting the install of the Citrix Workspace Client Package"
	Start-Process -FilePath "C:\ImageBuild\Citrix Workspace\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Start-Sleep -Seconds 120
    # Define the path to the log file
    $CitrixlogFilePath = "C:\Windows\PackageLogs\Citrix-Workspace\Citrix_Citrix-Workspace_20.2.0.25_X86_English_01_PSAppDeployToolkit_Install.log"

    # Define the text to search for
    $searchText = "Installation completed with exit code [0]"

    # Loop until the text is found or the script is manually stopped
    while ($true) {
    # Check if the log file exists
    if (Test-Path $CitrixlogFilePath) {
        # Read the log file
        $logContent = Get-Content $CitrixlogFilePath

        # Check if the log contains the search text
        if ($logContent -like "*$searchText*") {
            Write-Host "Installation completed successfully."
            $status = $true
            break
        } elseif ($logContent -match "exit code \[\d+\]") {
            Write-Host "Installation failed with exit code."
            $status = $false
            break
        }
    } else {
        Write-Host "Log file not found. Waiting for file to be created..."
    }

    # Wait for a bit before checking again
    Start-Sleep -Seconds 10
    
}

# Return the status
return $status
Write-Log "Successfully Completed the install of the Citrix Workspace Client Package"

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing CitrixWorkspace: $ErrorMessage"
    Exit 42
}

#Danfoss-SVD_StoreView_ver1.22.05b

try 
{
    Write-Log "Starting the install of the Danfoss-SVD_StoreView Package"
	Start-Process -FilePath "C:\ImageBuild\Danfoss-SVD_StoreView_ver1.22.05b\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Danfoss-SVD_StoreView Package"

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Danfoss-SVD_StoreView_ver1.22.05b: $ErrorMessage"
    Exit 42
}

#IEX (silent install?)

try 
{
    Write-Log "Starting the install of the Danfoss-SVD_StoreView Package"
	Start-Process -FilePath "C:\ImageBuild\IEX\rcp-installer-7.5.2.0.exe" -ArgumentList "/passive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Danfoss-SVD_StoreView Package"

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Danfoss-SVD_StoreView_ver1.22.05b: $ErrorMessage"
    Exit 42
}

#MarchSuite

try 
{
    Write-Log "Starting the install of the March Suite Package"
	Start-Process -FilePath "C:\ImageBuild\MarchSuite\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the March Suite Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing MarchSuite: $ErrorMessage"
    Exit 42
}

#NextivaReview

try 
{
    Write-Log "Starting the install of the Nextiva Review Package"
	Start-Process -FilePath "C:\ImageBuild\NextivaReview\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Nextiva Review Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing NextivaReview: $ErrorMessage"
    Exit 42
}

#NiceQM

try 
{
    Write-Log "Starting the install of the Nice QM Package"
	Start-Process -FilePath "C:\ImageBuild\NICE-QM\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Nice QM Package"
}
catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing NiceQM: $ErrorMessage"
    Exit 42
}

#Novar_ESS32

try 
{
    Write-Log "Starting the install of the Novar ESS32 Package"
	Start-Process -FilePath "C:\ImageBuild\Novar ESS32\NOVAR_ESS32.EXE" -ArgumentList "/S /NOREBOOT" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Novar ESS32 Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Novar_ESS32: $ErrorMessage"
    Exit 42
}

#OperatorLookup

try 
{
    Write-Log "Starting the install of the Operator Lookup Package"
	Start-Process -FilePath "C:\ImageBuild\Operator Lookup\Operator_Lookup.EXE" -ArgumentList "/S" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Operator Lookup Package"
}

catch
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing OperatorLookup: $ErrorMessage"
    Exit 42
}

#Opus 

try 
{
    Write-Log "Starting the install of the Opus Package"
	Start-Process -FilePath "C:\ImageBuild\Opus\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Opus Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Opus: $ErrorMessage"
    Exit 42
}

#ProSpaceLauncher 

try 
{
    Write-Log "Starting the install of the ProSpace Launcher Package"
	Start-Process -FilePath "C:\ImageBuild\ProSpace Launcher US\ProspaceLauncher_US-1.1.9.msi" -ArgumentList "/qn" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the ProSpace Launcher Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing ProSpaceLauncher: $ErrorMessage"
    Exit 42
}

#Silverlight 

try 
{
    Write-Log "Starting the install of the Silverlight Package"
	Start-Process -FilePath "C:\ImageBuild\Silverlight\Silverlight_x64.exe" -ArgumentList "/q" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Silverlight Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Silverlight: $ErrorMessage"
    Exit 42
}

#SpacePlanning 

try 
{
    Write-Log "Starting the install of the Space Planning Package"
	Start-Process -FilePath "C:\ImageBuild\SpacePlanning\SpacePlanning.EXE" -ArgumentList "/S" -Wait -ErrorAction Stop
    $folderPath = "C:\Windows\PackageLogs\SpacePlanning"
    $fileType = "*.wmt"
	$processName = "SHUTDO~1"
    $processName1 = "pcaui"

	while ($true) {
    	if (Test-Path $folderPath) {
       		$files = Get-ChildItem $folderPath -Filter $fileType
       		if ($files.Count -gt 0) {
           		Write-Log "Found $($files.Count) $fileType files in $folderPath"
				Start-Sleep -Seconds 15
           		Stop-Process -Name $processName -Force
           		Write-Log "$processName process has been stopped"
                Start-Sleep -Seconds 15
                Stop-Process -Name $processName1 -Force 
                Write-Log "$processName1 process has been stopped"
           	break
       	} else {
           	#Write-Output "No $fileType files found in $folderPath"
    }
    } else {
       	#Write-Output "$folderPath does not exist"
}
    		Start-Sleep -Seconds 5
}	
    Write-Log "Successfully Completed the install of the Space Planning Package"
}

catch
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing SpacePlanning: $ErrorMessage"
    Exit 42
}

#UltraSite 

try 
{
    Write-Log "Starting the install of the Ultra Site Package"
	Start-Process -FilePath "C:\ImageBuild\UltraSite\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Ultra Site Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing UltraSite: $ErrorMessage"
    Exit 42
}

#BogleFont

try 
{
    Write-Log "Starting the install of the Bogle Font Package"
    Start-Process -FilePath "C:\ImageBuild\BogleFont\BogleFont-1.0.msi" -ArgumentList "/q ALLUSERS=2 /m MSIYXKCO /l* c:\Windows\temp\BogleFonts.log" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Bogle Font Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing BogleFont: $ErrorMessage"
    Exit 42
}
### Configuring Desktops Shortcuts ###
try 
{
	# Define the path to the CSV file and the Public Desktop directory
	$csvPath = "C:\ImageBuild\setdesktopshortcuts.csv" 
	$publicDesktopPath = "C:\Users\Public\Desktop"

	# Read the CSV file and create an array of filenames to keep
	$filesToKeep = Import-Csv -Path $csvPath | ForEach-Object { $_.Filename }

	# Get all the files in the Public Desktop directory
	$filesInPublicDesktop = Get-ChildItem -Path $publicDesktopPath

	# Start the logging process
	Write-Log "Starting the cleanup of the Public Desktop directory."

	foreach ($file in $filesInPublicDesktop) {
    	# Check if the current file is not in the list of files to keep
    	if ($file.Name -notin $filesToKeep) {
        	# Delete the file
        	Remove-Item -Path $file.FullName -Force
        	Write-Log "Successfully Deleted file: $($file.Name)"
    	}
}
	
}
catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error cleaning up the desktop icons: $ErrorMessage"
    Exit 42
}
# Installing CMTrace.exe
try 
{
	write-log "Copying CMTrace to System32 directory"
	Copy-Item "C:\ImageBuild\CMTrace.exe" -Recurse -Destination "C:\Windows\System32"
	write-log "Successfully copied the CMTrace.exe to the System32 Directory"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error copying CMTrace.exe: $ErrorMessage"
    Exit 42
}
