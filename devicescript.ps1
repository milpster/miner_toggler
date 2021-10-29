
$gameProcess = "proven_ground_client"
$miner = "miner"

function waitForProc {
	param(
		$invert = 0,
		$proc = "NONE"
	)
	$cqb = Get-Process $proc -ErrorAction SilentlyContinue
	if (-Not $invert) {
		Write-Output "waiting for proc: " $proc
		while (-Not $cqb) {
			Start-Sleep -Seconds:5
			Write-Host "polling for proc" $proc
			$cqb = Get-Process $proc -ErrorAction SilentlyContinue
		}
	} else {
		Write-Output "waiting for proc to end: " $proc 
		while ($cqb) {
			Start-Sleep -Seconds:10
			Write-Host "polling for proc end" $proc
			$cqb = Get-Process $proc -ErrorAction SilentlyContinue
		}
	}
	Start-Sleep -Seconds:5
}

function killMiner {
	#Stop-Process -Name "cmd"
	Stop-Process -Name "miner"
}

#hello i am main
while(1) {
	$proc = "GameCenter"
	waitForProc -invert 0 -proc $proc

	killMiner

	Get-PnpDevice -FriendlyName "*RX 570*" | Disable-PnpDevice -confirm:$false

	waitForProc -invert 0 -proc $gameProcess

	Start-Sleep -Seconds:10

	Get-PnpDevice -FriendlyName "*RX 570*" | Enable-PnpDevice -confirm:$false

	Start-Sleep -Seconds:1

	Start-Process -FilePath 'C:\gmin\mine_eth_rx570only.bat' -WorkingDirectory 'C:\gmin\'

	waitForProc -invert 1 -proc $gameProcess

	killMiner

	Start-Sleep -Seconds:5

	Start-Process -FilePath 'C:\gmin\mine_eth.bat' -WorkingDirectory 'C:\gmin\'	
}

