##################################################################
##################################################################
##								##
##			get-identidad				##
##								##
##								##
## selecciona la ultima parte de la identidad, para mostrar 	##
## con mas prolijidad en los reportes				##
##								##
## Pide y devuelve una variable de tipo String			##
##								##
## Autor: Lucas Camilo						##
## Fecha: 17/12/2012						##
##								##
##################################################################
##################################################################

function get-identidad( [string] $identidadcompleta) 
{
	$PIECES=$identidadcompleta.split("/") 
	$NUMBEROFPIECES=$PIECES.Count 
	$FILENAME=$PIECES[$NUMBEROFPIECES-1] 
	return $FILENAME
}
