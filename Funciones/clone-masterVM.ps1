function Clone-MasterVM {
<#  
.SYNOPSIS  Clone a VM without using vCenter   
.DESCRIPTION The function will clone a VM to a
  specified datastore. Optionally the new VM will be
  registered and powered on.
.NOTES  Author:  Luc Dekens  
.PARAMETER MasterName
  The name of the VM that will be cloned
.PARAMETER CloneName
  The name of the VM that is cloned
.PARAMETER DatastoreName
  The name of the datastore where the clone will be
  stored
.PARAMETER Register
  Register the clone on the vSphere server
.PARAMETER PowerOn
  Power on the clone. Can only be used when the Register
  switch is selected.
.EXAMPLE
  PS> Clone-MasterVM -MasterName M1 -CloneName Srv1 -DatastoreName DS1
#>
 
  param(
  [string]$MasterName,
  [string]$CloneName,
  [string]$DatastoreName,
  [switch]$Register,
  [switch]$PowerOn
  )
   
  $vm = Get-VM -Name $MasterName
  if($vm.ExtensionData.Snapshot -or $vm.PowerState -eq "PoweredOn"){
    Write-Error "The VM should be powered off and have no snapshots"
    return
  }
   
  $si = Get-View ServiceInstance
  $vdkMgr = Get-View $si.Content.virtualDiskManager
  $fileMgr = Get-View $si.Content.FileManager
   
  $dcMoRef = (Get-Datacenter -VM $vm).ExtensionData.MoRef
  $srcDSName = $vm.ExtensionData.Config.Files.VmPathName.Split(']')[0].Trim('[')
  $srcDS = Get-Datastore -Name $srcDSName
  $srcDSBrowser = Get-View $srcDS.ExtensionData.Browser
  $tgtDS = Get-Datastore -Name $DatastoreName
  $spec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
   
  # Create folder for new VM
  $fileMgr.MakeDirectory("[$DatastoreName] $CloneName",$dcMoRef,$false)
 
  # Copy vDisks
  $spec.Query = New-Object VMware.Vim.VmDiskFileQuery
  $qResult = $srcDSBrowser.SearchDatastore("[$srcDSName] $MasterName",$spec)
  if($qResult.File){
    $qResult.File | %{
      $srcPath = "$($qResult.FolderPath)/$($_.Path)"
      $tgtPath = $srcPath.Replace($srcDSName,$DatastoreName).Replace($MasterName,$CloneName)
      $hd = $vm.ExtensionData.Config.Hardware.Device |
        where {$_ -is [VMware.Vim.VirtualDisk] -and $_.Backing.FileName -eq $srcPath}
      $controller = $vm.ExtensionData.Config.Hardware.Device |
        where {$_.Key -eq $hd.ControllerKey}
      $vDiskSpec = New-Object VMware.Vim.VirtualDiskSpec
      $vDiskSpec.adapterType = &{
        if($controller -is [VMware.Vim.VirtualLsiLogicController] -or
          $controller -is [VMware.Vim.VirtualLsiLogicSASController] -or
          $controller -is [VMware.Vim.ParaVirtualSCSIController]){
          [VMware.Vim.VirtualDiskAdapterType]::lsiLogic
        }
        elseif($controller -is [VMware.Vim.VirtualBusLogicController]){
          [VMware.Vim.VirtualDiskAdapterType]::busLogic
        }
        else{
          [VMware.Vim.VirtualDiskAdapterType]::ide
        }
      }
      $vDiskSpec.diskType = &{
        if($hd.Backing.eagerlyScrub){[VMware.Vim.VirtualDiskType]::eagerZeroedThick}
        elseif($hd.Backing.thinProvisioned){[VMware.Vim.VirtualDiskType]::thin}
        else{[VMware.Vim.VirtualDiskType]::thick}}
      $vdkMgr.CopyVirtualDisk($srcPath,$dcMoRef,$tgtPath,$dcMoRef,$vDiskSpec,$null)
    }
  }
 
  # Copy other VM files
  $dsDestination = New-PSDrive -Location $tgtDS -Name dest -PSProvider VimDatastore -Root '\'
  Get-ChildItem -Path "vmstore:\ha-datacenter\$srcDSName\$MasterName" |
  where {"vmdk","log","vmsd" -notcontains $_.Name.Split('.')[1]} | %{
  # The copy is done in a foreach loop, to bypass a Copy-DatastoreItem bug with pipeline
  Copy-DatastoreItem -Item $_ `
     -Destination ("dest:\$CloneName\" + $_.Name.Replace($MasterName,$CloneName)) -Confirm:$false
  }
 
  # Update VMX file
  Copy-DatastoreItem -Item "dest:\$CloneName\$($CloneName).vmx" -Destination $env:Temp\t.vmx
  $text = Get-Content -Path $env:Temp\t.vmx | %{$_.Replace($MasterName,$CloneName)}
  $text | Set-Content -Path $env:Temp\t.vmx
  Copy-DatastoreItem -Item $env:Temp\t.vmx -Destination "dest:\$CloneName\$($CloneName).vmx" -Confirm:$false
 
  # Update VMXF file
  Copy-DatastoreItem -Item "dest:\$CloneName\$($CloneName).vmxf" -Destination $env:Temp\t.vmxf
  $text = Get-Content -Path $env:Temp\t.vmxf | %{$_.Replace($MasterName,$CloneName)}
  $text | Set-Content -Path $env:Temp\t.vmxf
  Copy-DatastoreItem -Item $env:Temp\t.vmxf -Destination "dest:\$CloneName\$($CloneName).vmxf" -Confirm:$false
   
  if($Register){
    New-VM -VMFilePath "[$DatastoreName] $CloneName\$($CloneName).vmx" | Out-Null
    if($PowerOn){
      Start-VM -VM $CloneName -ErrorAction SilentlyContinue
      Get-VMQuestion -VM $CloneName | Set-VMQuestion -DefaultOption -Confirm:$false
    }
  }
 
  Remove-PSDrive -Name dest -Confirm:$false
}