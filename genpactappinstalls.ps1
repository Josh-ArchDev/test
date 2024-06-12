
#######################################################################################################################
###                                                                                                                 ###
###    Script Name: genpactappinstalls.ps1                                                                          ###
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
 
$LogFilePath = "C:\ImageBuild\genpactappinstalls.log"
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


#SBOPAnalysisMSOffice


try 
{
	Write-Log "Starting the install of the SBOPAnalysisMSOffice Package"	
	Start-Process -FilePath "C:\ImageBuild\SBOPAnalysisMSOffice\SBOPAnalysisMSOffice.EXE" -ArgumentList "/S /NOREBOOT" -ErrorAction Stop
	$folderPath = "C:\Windows\PackageLogs\SBOPAnalysisMSOffice"
	$fileType = "*.wmt"
	$processName = "SHUTDO~1"
    #$processName1 = "pcaui"

	while ($true) 
	{
   		if (Test-Path $folderPath) 
		{
	    	$files = Get-ChildItem $folderPath -Filter $fileType
        	if ($files.Count -gt 0) 
			{
            	Write-Log "Found $($files.Count) $fileType files in $folderPath"
				Start-Sleep -Seconds 15
            	Stop-Process -Name $processName -Force
            	Write-Log "$processName process has been stopped"
				Write-Log "Successfully Completed the install of the SBOPAnalysisMSOffice Package"
                break
        	} 
			
    	} 
		else 
		{
        	Write-Log "$folderPath does not exist"
    	}
    	
		Start-Sleep -Seconds 5
	}		

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing SBOPAnalysisMSOffice: $ErrorMessage"
	Exit 42
}


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

#DocumentDirect4.4

try 
{
	Write-Log "Starting the install of the DocumentDirect Package"	
	Start-Process -FilePath "C:\ImageBuild\DocumentDirect\documentdirect.EXE" -ArgumentList "/S /NOREBOOT" -Wait -ErrorAction Stop
	Write-Log "Successfully Completed the install of the DocumentDirect Package"

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing DocumentDirect4.4: $ErrorMessage"
	Exit 42
}

#SAP_Client_GUI_64bit_ver[770c]

try 
{
	Write-Log "Starting the install of the SAP Client GUI Package"
	Start-Process -FilePath "C:\ImageBuild\SAP_Client_GUI_64bit_ver``[770c``]\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
	Write-Log "Successfully Completed the install of the SAP Client GUI Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing SAP_Client_GUI_64bit_ver[770c]: $ErrorMessage"
	Exit 42
}		

#SAPGUI ENDUSER INI_ver[0.0.80]

try 
{
	Write-Log "Starting the install of the SAP End User INI Package"	
	Start-Process -FilePath "C:\ImageBuild\SAPGUI ENDUSER INI_ver``[0.0.80``]\sapgui_ini_enduser-6.7.msi" -ArgumentList "/quiet" -Wait -ErrorAction Stop
	Write-Log "Successfully Completed the install of the SAP End User INI Package"

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing SAPGUI ENDUSER INI_ver[0.0.80]: $ErrorMessage"
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
	while ($true) 
	{
   		if (Test-Path $folderPath) 
		{
       		$files = Get-ChildItem $folderPath -Filter $fileType
       		if ($files.Count -gt 0) 
			{
           		Write-Log "Found $($files.Count) $fileType files in $folderPath"
				Start-Sleep -Seconds 10
           		Stop-Process -Name $processName -Force
				Write-Log "$processName process has been stopped"
				Write-Log "Successfully Completed the install of the Right Now Service Package"
           		
           	break
       	 	} 
		} 
	
   		Start-Sleep -Seconds 5
		
}	

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing RightNowService: $ErrorMessage"
	Exit 42
}

#BogleFont

try 
{
	Write-Log "Starting the install of the Bogle Font Package"	
	Start-Process -FilePath "C:\ImageBuild\BogleFont\BogleFont-1.0.msi" -ArgumentList "/q ALLUSERS=2 /m MSIYXKCO /l* c:\Windows\temp\BogleFonts.log" -Wait -ErrorAction Stop
	Write-Log "Successfully Compeleted the install of the Bogle Font Package"

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
	$csvPath = "C:\ImageBuild\UtilityScripts\setdesktopshortcuts.csv" # Replace with the actual path to your CSV file
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

### Register DLL and Copy TeamsMeetingAdd-in ###
try 
{
    # Define the source and destination paths
    Write-Log "Starting the installation of the Teams Meeting Add-in for Outlook"
    $sourcePath = "C:\ImageBuild\TeamsMeetingAdd-in"
    $destPath = "C:\Users\default\AppData\Local\Microsoft\"
    $dllPath = "C:\Users\default\AppData\Local\Microsoft\TeamsMeetingAdd-in\1.24.13005\x64\Microsoft.Teams.AddinLoader.dll" 

    # Copy the TeamsMeetingAdd-in folder to the destination
    Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
    Write-Log "Successfully copied TeamsMeetingAdd-in to $destPath"

    # Register the DLL
    #$dllPath = Join-Path -Path $destPath -ChildPath $dllName
    Start-Process -FilePath "C:\Windows\SysWOW64\Regsvr32.exe" -ArgumentList "/s `"$dllPath`"" -Wait
    Write-Log "Successfully registered $dllName"
    Write-Log "Successfully Completed the installation of the Teams Meeting Add-in for Outlook Package."
}
catch 
{
    $ErrorMessage = $_.Exception.Message
    Write-Log "Error occurred: $ErrorMessage"
    Exit 42
}

# Creating additional desktop shortcuts.
Write-Log "Creating the MS Outlook and File Explorer shortcuts on the desktop for all users."
try 
{
	$publicDesktop = [System.Environment]::GetFolderPath('CommonDesktopDirectory')
	$outlookPath = "C:\Program Files\Microsoft Office\root\Office16\OUTLOOK.EXE"
	$fileExplorerPath = "C:\Windows\explorer.exe"
	Write-Log "Creating the Outlook Shortcut"
	$outlookShortcut = $publicDesktop + "\Microsoft Outlook.lnk"
	$shell = New-Object -ComObject WScript.Shell
	$shortcut = $shell.CreateShortcut($outlookShortcut)
	$shortcut.TargetPath = $outlookPath
	$shortcut.Save()
	Write-Log "Creating the File Explorer Shortcut"
	$fileExplorerShortcut = $publicDesktop + "\Windows File Explorer.lnk"
	$shortcut = $shell.CreateShortcut($fileExplorerShortcut)
	$shortcut.TargetPath = $fileExplorerPath
	$shortcut.Save()
}
catch 
{
	$ErrorMessage = $_.Exception.message
    write-log "Error creating a shortcut $ErrorMessage"
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

# Copy MDE Onboarding File to the C:\Windows\Temp directory where a Scheduled Task will call it after domain join
try 
{
    $scriptsourcePath = "C:\ImageBuild\UtilityScripts\WindowsDefenderATPLocalOnboardingScript.cmd"
	$scriptdestinationPath = "C:\Windows\Temp\WindowsDefenderATPLocalOnboardingScript.cmd"
	$STRemovalScriptPath = "C:\ImageBuild\UtilityScripts\Remove-MDEOnboardingST.ps1"
	Write-Log "Starting the copy of the WindowsDefenderATPLocalOnboardingScript.cmd file"
	if (Test-Path -Path $scriptsourcePath) 
	{
		# Copy the file to the destination
		Copy-Item -Path $scriptsourcePath -Destination $scriptdestinationPath
		Write-Log "The WindowsDefenderATPLocalOnboardingScript.cmd File copied successfully."
	}
	Write-Log "Starting the copy of the Remove-MDEOnboardingST.ps1 file"
	if (Test-Path -Path $STRemovalScriptPath) 
	{
		# Copy the file to the destination
		Copy-Item -Path $STRemovalScriptPath -Destination "C:\Windows\Temp\Remove-MDEOnboardingST.ps1"
		Write-Log "The Remove-MDEOnboardingST.ps1 File copied successfully."
	}
	
}
Catch
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error copying the MDE Onboarding script to the C:\Windows\Temp : $ErrorMessage"
    Exit 42
}
