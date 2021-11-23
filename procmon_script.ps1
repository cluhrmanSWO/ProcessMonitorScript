$backingFile="LogFiles.PML"
$pmcFile="ProcmonConfiguration.pmc"
$csvTrace="LogFiles.csv"

procmon.exe /Quiet /AcceptEula /BackingFile `"$backingFile`" /Minimized /LoadConfig `"$pmcFile`"

Start-Sleep -s 20

procmon.exe /Terminate

while (Get-Process procmon -ErrorAction Ignore) {
             Write-Host "Waiting on procmon to exit..."
             Start-Sleep -s 10
}

$result = Get-Childitem -Path "..\" -Include LogFiles.PML -Recurse -ErrorAction SilentlyContinue

if ($result -eq $null){
    write-host  "You Do not have PML file to export "
}else {
    procmon.exe /SaveApplyFilter /OpenLog `"$backingFile`" /SaveAs `"$csvTrace`" 
}

$pmlStatus = $true

while ($pmlStatus){
	write-host "Waiting for CSV to create..."
	Start-Sleep -s 2

	try
	{
		Remove-Item 'C:\KHC_ProcMon\ProcessMonitor\LogFiles.PML'
		$pmlStatus = $false
	}
	catch
	{
		write-host "Waiting for CSV to create..."
	}
}

write-host "PML deleted"