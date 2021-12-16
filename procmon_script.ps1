function Start-Sleep($seconds) {
    	$doneDT = (Get-Date).AddSeconds($seconds)
    	while($doneDT -gt (Get-Date)) {
        	$secondsLeft = $doneDT.Subtract((Get-Date)).TotalSeconds
        	$percent = ($seconds - $secondsLeft) / $seconds * 100
        	Write-Progress -Activity "Progress Timer" -Status "Collecting" -SecondsRemaining $secondsLeft -PercentComplete $percent
        	[System.Threading.Thread]::Sleep(500)
    	}
   	Write-Progress -Activity "Sleeping" -Status "Sleeping..." -SecondsRemaining 0 -Completed
}
$hn = hostname
$backingFile="${hn}_LogFiles.PML"
$pmcFile="ProcmonConfiguration.pmc"
$csvTrace="${hn}_LogFiles.csv"
$csvOutput="${hn}_allOutput.csv"
$pmlStatus = $true
$procmon="Process Monitor"

cd KHC_ProcessMonitor

#This loop will run 7 times; 7 days in a week
for ($j = 1; $j -lt 8; $j++){
	Write-Host "Day $j of 7"
	#This for loop runs 24 times; 24 hours in a day
	for ($i = 1; $i -lt 25; $i++){
		Write-Host "------------------------------------------------------------------------------------"
		Write-Host "Cycle $i of 24"

		Write-Host "Starting $procmon"
		.\Procmon.exe /Quiet /AcceptEula /BackingFile `"$backingFile`" /Minimized /LoadConfig `"$pmcFile`"
		Write-Host "$procmon is running"

	#Set this command to 3600 for $procmon to run for 1 hour
		Start-Sleep -s 30

		Write-Host "Closing $procmon"
		$procmonkilljob = Start-job { Procmon.exe /Terminate }
		Wait-Job $procmonkilljob
		Write-Host "$procmon closed"

		Write-Host "Saving log files"
		$result = Get-Childitem -Path "..\" -Include $backingFile -Recurse -ErrorAction SilentlyContinue
		if ($result -eq $null){
			Write-Host "You do not have PML file to export"
		}else {
			.\Procmon.exe /SaveApplyFilter /OpenLog `"$backingFile`" /SaveAs `"$csvTrace`" 
		}
		
	#Checking for LogFile.csv. Once found, transfer data from LogFile.csv -> allOutput.csv
		while(!(Get-Item $csvTrace -ErrorAction Ignore)){
			Write-Host "Writing data..."
			Start-Sleep -s 5
		}
		Write-Host "Writing $csvTrace to $csvOutput"
		Get-Content $csvTrace| Add-Content ../$csvOutput

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
		$pmlStatus = $true

		Write-Host "$backingFile deleted"
		Remove-Item $csvTrace
		Write-Host "$csvTrace deleted"
	}
}
cd ..
Remove-Item KHC_ProcessMonitor -Force -Recurse
Remove-Item procmon_script.ps1 -Force
