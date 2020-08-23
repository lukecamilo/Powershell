# Start-LoggedService

## Description 
Inicializa un servicio $Service _(si hay varios similares solo usa el primero)_ y loggea servicio, status y hora en $LogPath.  
Si $LogPath no se pasa por parametro, defaultea a c:\temp\$service.log
        
## Requirements
1. El servicio debe existir

## How to use
Admite los parametros -Servicio __(Obligatorio)__, -LogPath y -Silent  
Usar -Silent para que no escriba nada en pantalla  
Tambien deberia aceptar multiples inputs pipeados, pero no lo probe ¯\\\_(ツ)_/¯

## Current Version
![Version](https://img.shields.io/badge/Version-1.0-brightgreen?logo=powershell)   
- 2020/08/23 
- First release
