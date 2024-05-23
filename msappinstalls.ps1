#######################################################################################################################
###                                                                                                                 ###
###    Script Name: msappinstalls.ps1                                                                               ###
###    Script Function: This script is meant to be run within a Custom Image Template deployment within Azure       ###
###                     Virtual Desktop. This script installs the required software for the Microsoft Use case      ###
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
 
$LogFilePath = "C:\ImageBuild\MSappinstalls.log"
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


#
#Windows Subsystem for Linux (This will enable the feature, The user will need to install the distro as it prompts to create a user account immediately after the install)
#Install Ubuntu: wsl --install -d Ubuntu

try 
{
    Write-Log "Starting the install of the Windows Subsystem for Linux"	
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Write-Log "Successfully Completed the install of the Windows Subsystem for Linux"
}
catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing dotnetfx35: $ErrorMessage"
    Exit 42
}

#.NET 5.0

try 
{
    Write-Log "Starting the install of the .Net 5.0 Package"
    Start-Process -FilePath "C:\ImageBuild\dotnet5.0.12\windowsdesktop-runtime-5.0.12-win-x64.exe" -ArgumentList "/install /quiet /norestart" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the .Net 5.0 Package"
}
catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing DAX_Studio_ver3.0.8.945: $ErrorMessage"
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
#Chrome
<# 
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
 #>
#Notepad++ v7.7.1

try 
{
    Write-Log "Starting the install of the Notepad++ Package"
    Start-Process -FilePath "C:\ImageBuild\Notepad++_ver``[7.7.1``]\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Notepad++ Package"
}

catch 
{
    $ErrorMessage = $_.Exception.message
   	write-log "Error installing Notepad++_ver[7.7.1]: $ErrorMessage"
    Exit 42
}

#VSCode

try 
{
    Write-Log "Starting the install of the VSCode Package"
    Start-Process -FilePath "C:\ImageBuild\VSCode\VSCodeUserSetup-x64-1.85.1.exe" -ArgumentList "/verysilent /suppressmsgboxes /mergetasks=!runcode" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the VSCode Package"
}

catch 
{
    $ErrorMessage = $_.Exception.message
   	write-log "Error installing VSCodeUserSetup-x64-1.85.1: $ErrorMessage"
    Exit 42
}

#Git

try 
{
    Write-Log "Starting the install of the GIT Package"
    Start-Process -FilePath "C:\ImageBuild\Git\Git-2.33.0-64-bit.exe" -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the GIT Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Git-2.33.0-64-bit: $ErrorMessage"
    Exit 42
}

#Postman (installs correctly, but must reboot, then login for the installation to complete)

try 
{
    Write-Log "Starting the install of the Postman Package"	
    Start-Process -FilePath "C:\ImageBuild\Postman_ver7.34.0\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Postman Package"	
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Postman_ver7.34.0: $ErrorMessage"
    Exit 42
}

#Node.js

try 
{
Write-Log "Starting the install of the Node.js Package"		
Start-Process -FilePath "C:\ImageBuild\Nodejs\node-v10.16.3-x64.msi" -ArgumentList "/quiet /norestart" -Wait -ErrorAction Stop
Write-Log "Successfully Completed the install of the Node.js Package"	
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing node-v10.16.3-x64: $ErrorMessage"
    Exit 42
}


#DAX_Studio

try 
{

	Write-Log "Starting the install of the DAX Studio Package"		
    Start-Process -FilePath "C:\ImageBuild\DAX Studio_ver3.0.8.945\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the DAX Studio Package"		

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing DAX_Studio_ver3.0.8.945: $ErrorMessage"
    Exit 42

}


#AzureDataStudio 

try 
{
    Write-Log "Starting the install of the Azure Data Studio Package"		
    Start-Process -FilePath "C:\ImageBuild\AzureDataStudio\azuredatastudio-windows-setup-1.47.0.exe" -ArgumentList "/VERYSILENT /MERGETASKS=!runcode" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Azure Data Studio Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing azuredatastudio-windows-setup-1.47.0: $ErrorMessage"
    Exit 42
}

#Powershell7.4.0

try 
{
    Write-Log "Starting the install of the PowerShell 7 Package"
    Start-Process -FilePath "C:\ImageBuild\Powershell7.4.0\PowerShell-7.4.0-win-x64.msi" -ArgumentList "/quiet" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the PowerShell 7 Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Powershell7.4.0: $ErrorMessage"
    Exit 42
}

#AzureCLI

try 
{
    Write-Log "Starting the install of the Azure CLI Package"	
    Start-Process -FilePath "C:\ImageBuild\AzureCLI\azure-cli-2.55.0-x64.msi" -ArgumentList "/quiet" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Azure CLI Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing azure-cli-2.55.0-x64: $ErrorMessage"
    Exit 42
}

#Python 3.10.5

try 
{
    Write-Log "Starting the install of the Python 3.10.5 Package"	
    Start-Process -FilePath "C:\ImageBuild\Python\python-3.10.5-amd64.exe" -ArgumentList "/quiet InstallAllUsers=1 TARGETDIR=C:\Program Files\Python310" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Python 3.10.5 Package"	

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing python-3.10.5: $ErrorMessage"
    Exit 42
}

#SQLServerManagementStudio

try 
{
    Write-Log "Starting the install of the SQL Server Management Studio Package"		
    Start-Process -FilePath "C:\ImageBuild\SSMS\SSMS-Setup-ENU.exe" -ArgumentList "/quiet /install /norestart" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the SQL Server Management Studio Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing SSMS: $ErrorMessage"
    Exit 42
}

#PowerBI

try 
{
    Write-Log "Starting the install of the Power BI Package"	
    Start-Process -FilePath "C:\ImageBuild\PowerBI_ver2.121.762\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Power BI Package"	

}
catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing SSMS: $ErrorMessage"
    Exit 42
}

#ALMToolkit (Install after PowerBI)

try 
{
    Write-Log "Starting the install of the ALM Toolkit Package"		
    Start-Process -FilePath "C:\ImageBuild\ALM_Toolkit_verv5.0.22\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the ALM Toolkit Package"		
}

catch 
{
	$ErrorMessage = $_.Exception.message
  	write-log "Error installing ALM_Toolkit_verv5.0.22: $ErrorMessage"
    Exit 42
}

#Slack


try 
{
    Write-Log "Starting the install of the Slack Package"			
    Start-Process -FilePath "C:\ImageBuild\Slack_4.36.136\slack-standalone-4.36.136.0.msi" -ArgumentList "/quiet" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Slack Package"

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Slack_4.36.136: $ErrorMessage"
    Exit 42
}

# PowerShell script to create web shortcuts (.URL files) for Office Web Apps on the desktop for all users with custom icons, error handling, and logging

# Define shortcut locations
Write-Log "Configuring Desktop Shortcuts for Office Web App Links"
$desktopPath = [System.Environment]::GetFolderPath('CommonDesktopDirectory')

# Copy icon files to System32 directory

try 
{
	write-log "Copying Office icons to System32 directory"
	Copy-Item "C:\ImageBuild\OfficeIcons" -Recurse -Destination "C:\Windows\System32"
	write-log "Successfully copied the Office icon files"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error copying Office icon files: $ErrorMessage"
    Exit 42
}

# Define Office Web Apps URLs and their corresponding custom icon paths
$officeApps = @{
    "Microsoft Word" = @{
        "URL" = "https://office.live.com/start/Word.aspx";
        "Icon" = "C:\Windows\System32\OfficeIcons\word.ico"
    }
    "Microsoft Excel" = @{
        "URL" = "https://office.live.com/start/Excel.aspx";
        "Icon" = "C:\Windows\System32\OfficeIcons\excel.ico"; # Update path to your custom icon
    }
    "Microsoft PowerPoint" = @{
        "URL" = "https://office.live.com/start/PowerPoint.aspx";
        "Icon" = "C:\Windows\System32\OfficeIcons\PowerPoint.ico"; # Update path to your custom icon
    }
    "Microsoft OneNote" = @{
        "URL" = "https://www.onenote.com/notebooks";
        "Icon" = "C:\Windows\System32\OfficeIcons\OneNote.ico"; # Update path to your custom icon
    }
    "Microsoft Outlook" = @{
        "URL" = "https://outlook.wal-mart.com/mail";
        "Icon" = "C:\Windows\System32\OfficeIcons\outlook.ico"; # Update path to your custom icon
    }
}

# Loop through each app and create a web shortcut on the desktop
Write-Log "Creating Desktop Icons for Office Web Apps"
foreach ($appName in $officeApps.Keys) {
    $appDetails = $officeApps[$appName]
    $url = $appDetails["URL"]
    $icon = $appDetails["Icon"]
    $shortcutPath = Join-Path -Path $desktopPath -ChildPath "$appName.url"

    try {
        $shortcutContent = @"
[InternetShortcut]
URL=$url
IconFile=$icon
IconIndex=0
"@
        $shortcutContent | Out-File -FilePath $shortcutPath
        Write-Log "Successfully created web shortcut for $appName with custom icon on the desktop for all users."
    } catch {
        Write-Log "Failed to create web shortcut for $appName. Error: $_"
        Exit 42
    }
}

Write-Host "Web shortcuts with custom icons created successfully on the desktop for all users."
Write-Log "Completed creating web shortcuts with custom icons on the desktop for all users."

#Copy FSLogix Rules

try 
{
    Write-Log "Checking for the FSLogix Rules directory."
    $rulesDirectory = 'C:\Program Files\FSLogix\Apps\Rules\Rules'
    
    # Check if the Rules directory exists, create it if it does not
    if (-not (Test-Path -Path $rulesDirectory)) {
        New-Item -Path $rulesDirectory -ItemType Directory
        Write-Log "FSLogix Rules directory created."
    }

    Write-Log "Starting the copy of the FSLogix App Masking Rules" 
    Copy-Item -Path C:\ImageBuild\FSLogixRules\* -Destination $rulesDirectory -Recurse
    Write-Log "Successfully Completed the copy of the FSLogix App Masking Rules" 

}
catch 
{
    $ErrorMessage = $_.Exception.message
    write-log "Error copying FSLogixRules: $ErrorMessage"
    Exit 42
}

### Configuring Desktops Shortcuts ###
try 
{
	# Define the path to the CSV file and the Public Desktop directory
	$csvPath = "C:\ImageBuild\setdesktopshortcuts.csv" # Replace with the actual path to your CSV file
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
