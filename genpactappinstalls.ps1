
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
		# Log message to console and file
		Write-Host $Message
		Add-Content -Path $LogFilePath -Value "$(Get-Date) - $Message"

	}
	catch
	{
		write-host "Having issues creating or adding information to the logfile at $LogFilePath"
	}
}
	
 
#ForcePoint

try {
 
    Write-Log "Starting the ForcePoint Install"
	Start-Process -filepath 'C:\ImageBuild\FP-22.06\FORCEPOINT-ONE-ENDPOINT-x64.exe' -ArgumentList '/v" /quiet /norestart"' -Wait -ErrorAction Stop
	Write-Log "Successfully installed the ForcePoint Software"
    #Start-Sleep -Seconds 300
}
 
catch {
 
    $ErrorMessage = $_.Exception.message
 
    write-log "Error installing ForcePoint-v22.06.5578: $ErrorMessage"
	Exit 42
 
}

#Tanium

try {
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

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing ForcePoint-v22.06.5578: $ErrorMessage"
		Exit 42

	}

#Trellix Proxy Agent

try {

	Write-Log "Starting the Trellix Proxy Agent Install"	
	Start-Process -FilePath "C:\ImageBuild\FramePkg581L.exe" -ArgumentList "/install=agent /silent" -Wait -ErrorAction Stop
	Write-Log "Successfully Completed the Trellix Proxy Agent Install"

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing TrellixProxyAgent: $ErrorMessage"
		Exit 42

	}

#Frameworks

try {

		Write-Log "Starting the install of Visual C++ Redist x64 Package"
		Start-Process -FilePath "c:\ImageBuild\Frameworks\VC_redist.x64.exe" -ArgumentList "/quiet /norestart" -Wait -ErrorAction Stop
		Write-Log "Successfully Completed the install of Visual C++ Redist x64 Package"

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing VC_redist.x64.exe: $ErrorMessage"
		Exit 42

	}

try {

	Write-Log "Starting the install of Visual C++ Redist x86 Package"	
	Start-Process -FilePath "c:\ImageBuild\Frameworks\VC_redist.x86.exe" -ArgumentList "/quiet /norestart" -Wait -ErrorAction Stop
	Write-Log "Successfully Completed the install of Visual C++ Redist x64 Package"

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing VC_redist.x86.exe: $ErrorMessage"
		Exit 42

	}

try {

	Write-Log "Starting the install of the .Net 3.5 Package"	
	Add-WindowsCapability -Online -Name NetFx3 -Source "C:\ImageBuild\Frameworks\dotnetfx35.exe"
	Write-Log "Successfully Completed the install of the .Net 3.5 Package"	

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing dotnetfx35: $ErrorMessage"
		Exit 42

	}

#NewTeams

try {
 
    Write-Log "Starting the install of the New Teams Client Package"	
	Start-Process -filepath 'C:\ImageBuild\Microsoft_Teams_ver24004.1309.2689.2246\Deploy-Application.exe' -ArgumentList 'Install NonInteractive' -Wait -ErrorAction Stop
    #Start-Sleep -Seconds 300
	Write-Log "Successfully Completed the install of the New Teams Client Package"
}
 
catch {
 
    $ErrorMessage = $_.Exception.message
 
    write-log "Error installing NewTeams: $ErrorMessage"
	Exit 42
 
}

#SBOPAnalysisMSOffice

try {
		Write-Log "Starting the install of the SBOPAnalysisMSOffice Package"	
		Start-Process -FilePath "C:\ImageBuild\SBOPAnalysisMSOffice\SBOPAnalysisMSOffice.EXE" -ArgumentList "/S /NOREBOOT" -ErrorAction Stop

		$folderPath = "C:\Windows\PackageLogs\SBOPAnalysisMSOffice"
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
			Write-Log "Successfully Completed the install of the SBOPAnalysisMSOffice Package"
}		

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing SBOPAnalysisMSOffice: $ErrorMessage"
		Exit 42

	}

#Alteryx

try {
		Write-Log "Starting the install of the Alteryx Package"
		Start-Process -FilePath "C:\ImageBuild\Alteryx_64bit_ver[2019.4g]\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
		Write-Log "Successfully Completed the install of the Alteryx Package"

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing Alteryx_2019.4g: $ErrorMessage"
		Exit 42

	}

#Reflection MultiHost

try {

		Write-Log "Starting the install of the Reflection MultiHost Package"
		Start-Process -FilePath "C:\ImageBuild\Reflection\Reflection_Multi_Host.EXE" -ArgumentList "/S /NOREBOOT" -Wait -ErrorAction Stop
		Write-Log "Successfully Completed the install of the Reflection MultiHost Package"

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing ReflectionMultiHost: $ErrorMessage"
		Exit 42

	}

#DocumentDirect4.4

try {

		Write-Log "Starting the install of the DocumentDirect Package"	
		Start-Process -FilePath "C:\ImageBuild\DocumentDirect\documentdirect.EXE" -ArgumentList "/S /NOREBOOT" -Wait -ErrorAction Stop
		Write-Log "Successfully Completed the install of the DocumentDirect Package"

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing DocumentDirect4.4: $ErrorMessage"
		Exit 42

	}

#SAP_Client_GUI_64bit_ver[770c]

try {

		Write-Log "Starting the install of the SAP Client GUI Package"
		Start-Process -FilePath "C:\ImageBuild\SAP_Client_GUI_64bit_ver``[770c``]\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop
		Write-Log "Successfully Completed the install of the SAP Client GUI Package"

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing SAP_Client_GUI_64bit_ver[770c]: $ErrorMessage"
		Exit 42

	}		

#SAPGUI ENDUSER INI_ver[0.0.80]

try {

		Write-Log "Starting the install of the SAP End User INI Package"	
		Start-Process -FilePath "C:\ImageBuild\SAPGUI ENDUSER INI_ver``[0.0.80``]\sapgui_ini_enduser-6.7.msi" -ArgumentList "/quiet" -Wait -ErrorAction Stop
		Write-Log "Starting the install of the SAP End User INI GUI Package"

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing SAPGUI ENDUSER INI_ver[0.0.80]: $ErrorMessage"
		Exit 42

	}
#RightNowService

try {
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

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing RightNowService: $ErrorMessage"
		Exit 42

	}


#Chrome

	try {

			Write-Log "Starting the install of the Google Chrome Package"
			Start-Process msiexec.exe -ArgumentList '/i c:\imagebuild\Chrome\googlechromestandaloneenterprise64.msi /qn' -Wait -ErrorAction Stop
			Write-Log "Successfully Completed the install of the Google Chrome Package"


}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing Chromev120: $ErrorMessage"
		Exit 42

	}

#BogleFont

try {

		Write-Log "Starting the install of the Bogle Font Package"	
		Start-Process -FilePath "C:\ImageBuild\BogleFont\BogleFont-1.0.msi" -ArgumentList "/q ALLUSERS=2 /m MSIYXKCO /l* c:\Windows\temp\BogleFonts.log" -Wait -ErrorAction Stop
		Write-Log "Successfully Compeleted the install of the Bogle Font Package"

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing BogleFont: $ErrorMessage"
		Exit 42

	}