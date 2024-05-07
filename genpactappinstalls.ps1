$LogFilePath = "C:\ImageBuild\genpactappinstalls.log"


# Function to log messages to console and file
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
 
    Start-Process -filepath 'C:\ImageBuild\FP-22.06\FORCEPOINT-ONE-ENDPOINT-x64.exe' -ArgumentList '/v" /quiet /norestart"' -Wait -ErrorAction Stop
    #Start-Sleep -Seconds 300
}
 
catch {
 
    $ErrorMessage = $_.Exception.message
 
    write-log "Error installing ForcePoint-v22.06.5578: $ErrorMessage"
 
}

#Tanium

try {
        $destination = "C:\Temp"
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

	}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing ForcePoint-v22.06.5578: $ErrorMessage"

	}

#Frameworks
try {

		Start-Process -FilePath "c:\ImageBuild\Frameworks\VC_redist.x64.exe" -ArgumentList "/quiet /norestart" -Wait -ErrorAction Stop

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing VC_redist.x64.exe: $ErrorMessage"

	}

try {

		Start-Process -FilePath "c:\ImageBuild\Frameworks\VC_redist.x86.exe" -ArgumentList "/quiet /norestart" -Wait -ErrorAction Stop

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing VC_redist.x86.exe: $ErrorMessage"

	}

try {

		Add-WindowsCapability -Online -Name NetFx3 -Source "C:\ImageBuild\Frameworks\dotnetfx35.exe"

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing dotnetfx35: $ErrorMessage"

	}

#NewTeams

try {
 
    Start-Process -filepath 'C:\ImageBuild\NewTeams\teamsbootstrapper (1).exe' -ArgumentList '-p -o "c:\ImageBuild\NewTeams\MSTeams-x64.msix"' -Wait -ErrorAction Stop
    #Start-Sleep -Seconds 300
}
 
catch {
 
    $ErrorMessage = $_.Exception.message
 
    write-log "Error installing NewTeams: $ErrorMessage"
 
}

#SBOPAnalysisMSOffice

try {

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
}		

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing SBOPAnalysisMSOffice: $ErrorMessage"

	}

#Alteryx

try {

		Start-Process -FilePath "C:\ImageBuild\Alteryx_64bit_ver[2019.4g]\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing Alteryx_2019.4g: $ErrorMessage"

	}

#Reflection MultiHost

try {

		Start-Process -FilePath "C:\ImageBuild\Reflection\Reflection_Multi_Host.EXE" -ArgumentList "/S /NOREBOOT" -Wait -ErrorAction Stop

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing ReflectionMultiHost: $ErrorMessage"

	}

#Notepad++ v7.7.1

try {

		Start-Process -FilePath "C:\ImageBuild\Notepad++_ver``[7.7.1``]\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing Notepad++_ver[7.7.1]: $ErrorMessage"

	}

#DocumentDirect4.4

try {

		Start-Process -FilePath "C:\ImageBuild\DocumentDirect\documentdirect.EXE" -ArgumentList "/S /NOREBOOT" -Wait -ErrorAction Stop

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing DocumentDirect4.4: $ErrorMessage"

	}

#SAP_Client_GUI_64bit_ver[770c]

try {

		Start-Process -FilePath "C:\ImageBuild\SAP_Client_GUI_64bit_ver``[770c``]\Deploy-Application.exe" -ArgumentList "Install NonInteractive" -Wait -ErrorAction Stop

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing SAP_Client_GUI_64bit_ver[770c]: $ErrorMessage"

	}		

#SAPGUI ENDUSER INI_ver[0.0.80]

try {

		Start-Process -FilePath "C:\ImageBuild\SAPGUI ENDUSER INI_ver``[0.0.80``]\sapgui_ini_enduser-6.7.msi" -ArgumentList "/quiet" -Wait -ErrorAction Stop

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing SAPGUI ENDUSER INI_ver[0.0.80]: $ErrorMessage"

	}
#RightNowService

try {

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
}	

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing RightNowService: $ErrorMessage"

	}


#Chrome

	try {

		Start-Process msiexec.exe -ArgumentList '/i c:\imagebuild\Chrome\googlechromestandaloneenterprise64.msi /qn' -Wait -ErrorAction Stop

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing Chromev120: $ErrorMessage"

	}

#BogleFont

try {

		Start-Process -FilePath "C:\ImageBuild\BogleFont\BogleFont-1.0.msi" -ArgumentList "/q ALLUSERS=2 /m MSIYXKCO /l* c:\Windows\temp\BogleFonts.log" -Wait -ErrorAction Stop

}

	catch {

		$ErrorMessage = $_.Exception.message
 
    	write-log "Error installing BogleFont: $ErrorMessage"

	}
