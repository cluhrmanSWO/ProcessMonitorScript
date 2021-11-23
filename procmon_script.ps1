$backingFile="LogFiles.PML"
$pmcFile="ProcmonConfiguration.pmc"
$csvTrace="LogFiles.csv"
$csvOutput="allOutput.csv"
$pmlStatus = $true
$procmon="Process Monitor"

cd KHC_ProcessMonitor

for ($i = 0; $i -lt 2; $i++){
#Change the above 2 ^ to 24
	Write-Host "Starting $procmon"
	.\Procmon.exe /Quiet /AcceptEula /BackingFile `"$backingFile`" /Minimized /LoadConfig `"$pmcFile`"
	Write-Host "$procmon is running"

#Change this to 3600 for this loop to occur every hour
	Start-Sleep -s 60

	Write-Host "Closing $procmon"
	.\Procmon.exe /Terminate

	while (Get-Process procmon -ErrorAction Ignore) {
		Write-Host "Waiting on $procmon to exit..."
		Start-Sleep -s 10
	}


	$result = Get-Childitem -Path "..\" -Include $backingFile -Recurse -ErrorAction SilentlyContinue
	if ($result -eq $null){
		Write-Host "You do not have PML file to export"
	}else {
		.\Procmon.exe /SaveApplyFilter /OpenLog `"$backingFile`" /SaveAs `"$csvTrace`" 
	}
	
	Write-Host "Waiting to write $csvTrace to $csvOutput"
	while(!(Get-Item $csvTrace -ErrorAction Ignore)){
		Start-Sleep -s 3
		try
		{
			Get-Content $csvTrace| Add-Content ..\$csvOutput
		}
		catch
		{
			Write-Host "Waiting to write $csvTrace to $csvOutput"
		}
	}
	
	Write-Host "Waiting to delete $backingFile"
	while ($pmlStatus){
		Start-Sleep -s 2
		try
		{
			Remove-Item $backingFile
			$pmlStatus = $false
		}
		catch
		{
			Write-Host "Waiting to delete $backingFile"
		}
	}

	Write-Host "$backingFile deleted"
	Remove-Item $csvTrace
	Write-Host "$csvTrace deleted"
}

cd ..
Remove-Item KHC_ProcessMonitor -Force -Recurse
Remove-Item procmon_script.ps1 -Force
