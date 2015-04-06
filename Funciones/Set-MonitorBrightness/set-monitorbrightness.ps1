function Set-MonitorBrightness
{
    param
    (
        [Parameter(Mandatory=$true)]
        [Int][ValidateRange(0,100)]
        $Value, 
        $ComputerName,
        $Credential
    ) 
    $null = $PSBoundParameters.Remove('Value') 
    $helper = Get-WmiObject -Namespace root/WMI -Class WmiMonitorBrightnessMethods @PSBoundParameters
    $helper.WmiSetBrightness(1, $Value)
}

function monitor-loco($compu){
	for($x=0; $x -lt 30; $x++){   
		Set-MonitorBrightness -Value (Get-Random -Minimum 0 -Maximum 101) -computername $compu 
		Start-Sleep -milliseconds 200   
	}
}
	