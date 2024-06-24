#######################################################################################################################
###                                                                                                                 ###
###    Script Name: engappinstalls.ps1                                                                             ###
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
 
$LogFilePath = "C:\ImageBuild\engappinstalls.log"
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
	Write-Log "Successfully Completed the ForcePoint Software Install."
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

#Python 3.10.5

try 
{
    Write-Log "Starting the install of the Python 3.10.5 Package"	
    Start-Process -FilePath "C:\ImageBuild\Python\python-3.10.5-amd64.exe" -ArgumentList "/quiet InstallAllUsers=1 TARGETDIR=C:\Program Files\Python310" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Python 3.10.5 Package"	
    Write-Log "Now installing Python Modules"
    Start-Process "C:\Program Files\Python310\Scripts\pip.exe" -ArgumentList "install google-cloud-storage" -Wait -ErrorAction Stop
    Start-Process "C:\Program Files\Python310\Scripts\pip.exe" -ArgumentList "install pandas" -Wait -ErrorAction Stop
    Start-Process "C:\Program Files\Python310\Scripts\pip.exe" -ArgumentList "install pandas-gbq" -Wait -ErrorAction Stop
    Start-Process "C:\Program Files\Python310\Scripts\pip.exe" -ArgumentList "install matplotlib" -Wait -ErrorAction Stop
    Start-Process "C:\Program Files\Python310\Scripts\pip.exe" -ArgumentList "install requests==2.29.0" -Wait -ErrorAction Stop
    Start-Process "C:\Program Files\Python310\Scripts\pip.exe" -ArgumentList "install gcsfs" -Wait -ErrorAction Stop
    Start-Process "C:\Program Files\Python310\Scripts\pip.exe" -ArgumentList "install beautifulsoup4" -Wait -ErrorAction Stop
    Write-Log "Successfully Installed the additional python modules"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing python-3.10.5: $ErrorMessage"
    Exit 42
}

### .Net 5.0 Install ###

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

#Java1.8

try 
{
    Write-Log "Starting the install of the Java 1.8 Client Package"	
	Start-Process -FilePath "C:\ImageBuild\Java1.8\Java_1.8.EXE" -ArgumentList "/S /NOREBOOT" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Java 1.8 Client Package"

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Java 1.8: $ErrorMessage"
    Exit 42
}

#Web RTC Redirector
try 
{
    Write-Log "Starting the install of the Web RTC Redirector Service to support Teams VDI Optimizations"
    Start-Process -FilePath "C:\ImageBuild\Frameworks\MsRdcWebRTCSvc_HostSetup_1.50.2402.29001_x64.msi" -ArgumentList "/quiet /norestart" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Web RTC Redirector Service Package"
}
catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Web RTC Redirector Service Package: $ErrorMessage"
    Exit 42
}


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
#Enable App-V

try 
{
    Write-Log "Starting the enablement of App-V"
    Enable-Appv 
    Write-Log "Successfully Completed the enablement of App-V"
}

catch 
{
    $ErrorMessage = $_.Exception.message
   	write-log "Error enabling App-V: $ErrorMessage"
    Exit 42
}




#FileZilla

try 
{
    Write-Log "Starting the install of the FileZilla Package"
    Start-Process -FilePath "C:\ImageBuild\FileZilla\FileZilla.EXE" -ArgumentList "/S /NOREBOOT" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the FileZilla Package"
}

catch 
{
    $ErrorMessage = $_.Exception.message
   	write-log "Error installing FileZilla: $ErrorMessage"
    Exit 42
}

#WireShark

try 
{
    Write-Log "Starting the install of the WireShark Package"
    Start-Process -FilePath "C:\ImageBuild\Wire-Shark\Wire_Shark.EXE" -ArgumentList "/S /NOREBOOT" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the WireShark Package"
}

catch 
{
    $ErrorMessage = $_.Exception.message
   	write-log "Error installing WireShark: $ErrorMessage"
    Exit 42
}

#FireFox

try 
{
    Write-Log "Starting the install of the FireFox Package"
    Start-Process -FilePath "C:\ImageBuild\Firefox\Firefox Setup 126.0.1.msi" -ArgumentList "/quiet /norestart" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the VSCode Package"
}

catch 
{
    $ErrorMessage = $_.Exception.message
   	write-log "Error installing VSCodeUserSetup-x64-1.85.1: $ErrorMessage"
    Exit 42
}

#nmap
<#
try 
{
    Write-Log "Starting the install of the nmap Package"
    Start-Process -FilePath "C:\ImageBuild\nmap\nmap-7.95-setup.exe" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the nmap Package"
}

catch 
{
    $ErrorMessage = $_.Exception.message
   	write-log "Error installing nmap: $ErrorMessage"
    Exit 42
}
#>

#UMS
<#
try 
{
    Write-Log "Starting the install of the UMS Package"
    Start-Process -FilePath "C:\ImageBuild\UMS\setup-igel-ums-windows_6.10.120.exe"  -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the UMS Package"
}

catch 
{
    $ErrorMessage = $_.Exception.message
   	write-log "Error installing UMS: $ErrorMessage"
    Exit 42
}
#>

#VMRC
<#
try 

{

    $INSTALLDIR = "C:\Program Files (x86)\VMware\VMware Remote Console"
    Write-Log "Starting the install of the VMRC Package"
    Start-Process -FilePath "C:\ImageBuild\VMRC\VMware-VMRC-12.0.5-22744838.exe" -ArgumentList "/s /v /qn EULAS_AGREED=1 INSTALLDIR='$INSTALLDIR' AUTOSOFTWAREUPDATE=0 DATACOLLECTION=0 /l c:\ImageBuild\VMRC-install.log"  -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the VMRC Package"
}

catch 
{
    $ErrorMessage = $_.Exception.message
   	write-log "Error installing VMRC: $ErrorMessage"
    Exit 42
}

#>
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

 
#MicrosoftEdgeWebview2

try 
{
	Write-Log "Starting the install of the Microsoft Edge WebView Package"
	Start-Process -FilePath "C:\ImageBuild\EdgeWebview2\MicrosoftEdgeWebview2Setup.exe" -ArgumentList '/silent /install' -Wait -ErrorAction Stop
	Write-Log "Successfully Completed the install of the Microsoft Edge WebView Package"

}

catch
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing MicrosoftEdgeWebview2: $ErrorMessage"
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

#Putty

try {

	Write-Log "Starting the install of the Putty Package"	
    Start-Process -FilePath "C:\ImageBuild\Putty\Putty.EXE" -ArgumentList "/S /NOREBOOT" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Putty Package"

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing 7-Zip: $ErrorMessage"
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

#IntelliJ

try 
{
    Write-Log "Starting the install of the InteliJ Package"
	Start-Process -FilePath "C:\ImageBuild\IntelliJ_Idea\IntelliJ_IDEA.EXE" -ArgumentList "/S /NOREBOOT" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the InteliJ Package"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing IntelliJ: $ErrorMessage"
    Exit 42
}

#Azul-Zulu_JDK-17_ver17.42.19

try 
{
    Write-Log "Starting the install of the Azul-Zulu JDK Package"
	Start-Process -FilePath "C:\ImageBuild\Azul-Zulu_JDK-17_ver17.42.19\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Azul-Zulu JDK Package"

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing Azul-Zulu_JDK-17_ver17.42.19: $ErrorMessage"
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

#VMWare DEM Management Console
try 
{
    Write-Log "Starting the install of the VMWare DEM Management Console Package"		
    Start-Process -FilePath "C:\ImageBuild\DEM\VMware Dynamic Environment Manager 9.11 x64.msi" -ArgumentList "/qn INSTALLDIR='C:\Program Files\Immidio\Flex Profiles\' ADDLOCAL='FlexManagementConsole' /l* InstallDEM.log" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the VMWare DEM Management Console Package"	
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing the VMWare DEM Management Console Package: $ErrorMessage"
    Exit 42
}

#VMWare HelpDesk Agent

try 
{
    Write-Log "Starting the install of the VMWare HelpDesk Agent Package"
    Start-Process -FilePath "C:\ImageBuild\HelpdeskAgent\VMwareHorizonHelpDeskAgentMSI-1.5.0.11.msi" -ArgumentList "/quiet /norestart" -Wait -ErrorAction Stop		
    Write-Log "Successfully Completed the install of the VMWare HelpDesk Agent Package Package"	
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing the VMWare HelpDesk Agent Package: $ErrorMessage"
    Exit 42
}

#Bomgar

try 
{
    Write-Log "Starting the install of the Bomgar Package"
    Start-Process -FilePath "C:\ImageBuild\Bomgar\bomgar-rep-win64-installer.msi" -ArgumentList "/quiet /norestart" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Bomgar Package"	
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing the Bomgar Package: $ErrorMessage"
    Exit 42
}

#Remote Desktop Connection Manager

try 
{
    Write-Log "Starting the install of the Remote Desktop Connection Manager Package"
    Start-Process -FilePath "C:\ImageBuild\RDCMan\RDCMan.msi" -ArgumentList "/quiet /norestart" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the Remote Desktop Connection Manager Package"	
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing the Remote Desktop Connection Manager Package: $ErrorMessage"
    Exit 42
}

#Local Administrator Password Solution

try 
{
    Write-Log "Starting the install of the LAPS Package"
    Start-Process -FilePath "C:\ImageBuild\LAPS\LAPS.x64.msi" -ArgumentList "/quiet /norestart" -Wait -ErrorAction Stop
    Write-Log "Successfully Completed the install of the LAPS Package"	
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing the LAPS Package: $ErrorMessage"
    Exit 42
}

#Remote Server Administration Tools (RSAT)

try 
{
    Write-Log "Starting the install of the RSAT Package"
    Add-WindowsCapability -Name "RSAT.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" -Online
    Write-Log "Successfully Completed the install of the RSAT Package"	
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing the RSAT Package: $ErrorMessage"
    Exit 42
}


#Installing Sysinternals Suite
try 
{
    # Define the source and destination directories
    $sourcePath = "C:\ImageBuild\SysinternalsSuite"
    $destinationPath = "C:\Windows\System32"
    $SysinternalsPath = $destinationPath + "\SysinternalsSuite"
	write-log "Copying Sysinternals Suite Files to C:\Windows\System32\SysinternalsSuite directory"
    # Copy the Sysinternals Suite directory to the destination
    Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse -Force

    # Verify the Sysinternals Suite directory is copied to C:\Windows\System32
    if (Test-Path -Path $SysinternalsPath) 
    {
        Write-Log "The Sysinternals Suite has been copied to $destinationPath."
    } 
    else 
    {
        Write-Log "Copy failed: The Sysinternals Suite has not been copied to $destinationPath."
    }

	# Get the current PATH environment variable value
    $currentPath = [System.Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine)

    # Check if the Sysinternals Suite directory is already in the PATH
    $Paths = $currentPath.Split(";")
    if ($Paths -notcontains $SysinternalsPath) 
    {
        # Add the Sysinternals Suite directory to the PATH environment variable
        $newPath = $currentPath + ";" + $SysinternalsPath
        [System.Environment]::SetEnvironmentVariable('PATH', $newPath, [System.EnvironmentVariableTarget]::Machine)
        Write-Log "The Sysinternals Suite directory has been added to the system PATH."
    } 
    else 
    {
        Write-Log "The Sysinternals Suite directory is already in the system PATH."
    }

}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error installing the Sysinternals Suite of tools: $ErrorMessage"
    Exit 42
}

# Remove Jave Automatic Updates Schedular
try 
{
	write-log "Removing the Java Update Scheduler from startup"
	$registryPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run"
    $registryKey = "SunJavaUpdateSched"
    Remove-ItemProperty -Path $registryPath -Name $registryKey
	write-log "Successfully removed the Java Update Scheduler from startup"
}

catch 
{
	$ErrorMessage = $_.Exception.message
   	write-log "Error removing the Java Update Scheduler from startup: $ErrorMessage"
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
