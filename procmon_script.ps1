$backingFile="LogFiles.PML"
$pmcFile="ProcmonConfiguration.pmc"
$csvTrace="LogFiles.csv"
$csvOutput="allOutput.csv"
$result = Get-Childitem -Path "..\" -Include $backingFile -Recurse -ErrorAction SilentlyContinue
$pmlStatus = $true
$procmon="Process Monitor"

for ($i = 0; $i -lt 24; $i++){
	Write-Host "Starting $procmon"
	procmon.exe /Quiet /AcceptEula /BackingFile `"$backingFile`" /Minimized /LoadConfig `"$pmcFile`"
	Write-Host "$procmon is running"

	Start-Sleep -s 30

	Write-Host "Closing $procmon"
	procmon.exe /Terminate

	while (Get-Process procmon -ErrorAction Ignore) {
		Write-Host "Waiting on $procmon to exit..."
		Start-Sleep -s 10
	}

	if ($result -eq $null){
		Write-Host "You do not have PML file to export"
	}else {
		procmon.exe /SaveApplyFilter /OpenLog `"$backingFile`" /SaveAs `"$csvTrace`" 
	}
	
	Write-Host "Waiting to write $csvTrace to $csvOutput"
	while(!(Get-Item $csvTrace -ErrorAction Ignore)){
		Start-Sleep -s 3
		try
		{
			Get-Content $csvTrace| Add-Content $csvOutput
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
