# List connected servers: $global:DefaultVIServers
# Connect to server: Connect-VIServer -server [SERVER_NAME]
# Disconnect from server: Disconnect-VIServer -server [SERVER_NAME]



function RenamePortGroupAndRemapVms ([String]$oldPortGroupName, [String]$newPortGroupName) {
	$StopWatch = [system.diagnostics.stopwatch]::startNew()
	Write-Host ""
	Write-Host "Renaming PortGroup $oldPortGroupName in $newPortGroupName and remap VMs network cards to the new PortGroup" -ForegroundColor Black -BackgroundColor Green
	Write-Host ""
	Write-Host "PortGroup renaming..."
	Get-VMHost | Get-VirtualPortGroup -Standard -Name $oldPortGroupName | Set-VirtualPortGroup -Name $newPortGroupName
	# Wait for network change propagation
	Start-Sleep -s 10
	Write-Host ""
	Write-Host "VMs network cards remapping..."
	Get-VM |Get-NetworkAdapter |Where {$_.NetworkName -eq $oldPortGroupName } |Set-NetworkAdapter -NetworkName $newPortGroupName -Confirm:$false
	Write-Host ""
	Write-Host "Operation duration = $($StopWatch.ElapsedMilliseconds/1000) s"
	Write-Host ""
	$StopWatch.Stop()
}

function CreatePortGroup ([String]$vSwitchName, [String]$portGroupName, [String]$vLanId) {
	Write-Host ""
	Write-Host "Create PortGroup $vSwitchName/$portGroupName (vlan $vLanId)..."
	Get-VMHost | Get-VirtualSwitch -Standard -Name $vSwitchName | New-VirtualPortGroup -Name $portGroupName -VLanId $vLanId
}

function DeletePortGroup ([String]$portGroupName) {
	Write-Host ""
	Write-Host "Delete PortGroup $portGroupName..."
	Get-VMHost | Get-VirtualPortGroup -Standard -Name $portGroupName | Remove-VirtualPortGroup -Confirm:$false
}

#RenamePortGroupAndRemapVms -oldPortGroupName "my old network name" -newPortGroupName "shiny new name"
#DeletePortGroup -portGroupName "port group name"
#CreatePortGroup -vSwitchName "vSwitch1" -portGroupName "port group name" -vLanId 460
