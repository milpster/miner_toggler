
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

function restartGpu {
	param(
		$name
	)
	Get-PnpDevice -FriendlyName "*$($name)*" | Disable-PnpDevice -confirm:$false
	Get-PnpDevice -FriendlyName "*$($name)*" | Enable-PnpDevice -confirm:$false
}

function killMiner {
	Stop-Process -Name "nbminer"
	Stop-Process -Name "miner"
	Stop-Process -Name "SRBMiner-MULTI"
	Stop-Process -Name "PhoenixMiner"
	Stop-Process -Name "NiceHashQuickMiner"
	Stop-Process -Name "excavator"
	Start-Sleep -Seconds:2
	Stop-Process -Name "cmd"
}

function startMiner {
	param(
		$amd=$true,
		$nv=$true
	)
	if($nv -eq $true) {
		Start-Process -FilePath 'C:\gmin\mine_eth_nvonly.bat' -WorkingDirectory 'C:\gmin\'
		#Start-Process -FilePath 'C:\gmin\excavator_v1.7.1d_build880_Win64\NiceHashQuickMiner.exe' -WorkingDirectory 'C:\gmin\excavator_v1.7.1d_build880_Win64\'
		Start-Sleep -Seconds:5
	}
	if($amd -eq $true) {
		Start-Process -FilePath 'C:\gmin\mine_eth_amdonly.bat' -WorkingDirectory 'C:\gmin\'
	}
}

#hello i am main
startMiner -amd true -nv true

while(1) {
	$proc = "GameCenter"
	waitForProc -invert 0 -proc $proc

	killMiner

	#we need to restart the first gpu aswell here, or else conquerors blade fps will be limited to 30 for some reason.
	restartGpu -name:"2080"

	Get-PnpDevice -FriendlyName "*RX 570*" | Disable-PnpDevice -confirm:$false
	Get-PnpDevice -FriendlyName "*390*" | Disable-PnpDevice -confirm:$false

	waitForProc -invert 0 -proc $gameProcess

	Start-Sleep -Seconds:10

	Get-PnpDevice -FriendlyName "*RX 570*" | Enable-PnpDevice -confirm:$false
	Get-PnpDevice -FriendlyName "*390*" | Enable-PnpDevice -confirm:$false

	Start-Sleep -Seconds:1

	startMiner -amd true -nv false

	waitForProc -invert 1 -proc $gameProcess

	killMiner

	Start-Sleep -Seconds:2
	
	startMiner -amd true -nv true
}

