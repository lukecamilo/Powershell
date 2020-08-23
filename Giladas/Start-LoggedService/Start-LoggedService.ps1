<#
    .SYNOPSIS
        Inicia un servicio y escribe un log.
       
    .DESCRIPTION
        Inicializa un servicio $Service y loggea servicio, status y hora en $LogPath.
        Si $LogPath no se pasa por parametro, defaultea a c:\temp\$service.log
         
    .PARAMETER LogPath
        Ruta donde se guarda el log.

    .PARAMETER Service
        Servicio a iniciar. 
    
    .PARAMETER Silent
        Si se usa este switch no escribe en pantalla
        
    .EXAMPLE
        Start-LoggedService -service openvpnservice -silent
        Inicia el servicio openvpnservice, loggea en c:\temp\openvpnservice.log y no muestra nada

        Start-LoggedService -LogPath C:\path\to\log.txt -service Sarlanga
        Inicia el servicio Sarlanga y loggea en c:\path\to\log.txt

    .NOTES
        Version:        1.0
        Author:         Lucas Camilo
        Change Date:    23/08/2020
        Purpose/Change: Original commit
 
#>

function Start-LoggedService {
    param (
        [Parameter(Mandatory)]
        [string]$Servicio,
    
        [Parameter()]
        [string]$LogPath,

        [Parameter()]
        [switch]$Silent
    )
    

    # Si no se define la ruta donde escribir el log
    if (!($logPath)) {
        $logPath="c:\temp\$servicio.log"
    }
    # Inicia el servicio $servicio
    $status=get-service $servicio | Select-Object -First 1 | Start-Service -PassThru | Select-Object -ExpandProperty status
    # Formatea la fecha
    $date= get-date -format "dd/MM/yyyy - HH:mm"
    # Define log a escribir
    $output= "$date - $Servicio $status" 
    # Escribe log al archivo
    $output | out-file $logPath -append
    
    if(!($Silent.IsPresent)){
        # Escribe log en pantalla
        Write-Host $output
    }

}