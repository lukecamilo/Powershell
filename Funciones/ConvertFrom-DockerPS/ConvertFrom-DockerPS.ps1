function ConvertFrom-DockerPS ($inStuff){
<#
	.SYNOPSIS
		Parses docker ps output to make it more readable
	
	.DESCRIPTION
		Pipe the results of Docker ps to this function and get the results in a nice, more powershelly format
	
	.PARAMETER
	
	
	.EXAMPLE
		docker ps | ConvertFrom-DockerPS | select names, image, "container id", created  # Get all running containers  
		docker ps -a | ConvertFrom-DockerPS | where {$_.status -like "exited*"} | docker  # Get all closed containers
		docker ps -a | ConvertFrom-DockerPS | where {$_.status -like "exited*"} | foreach { docker rm $_.'CONTAINER ID' }  # remove all stopped containers
		
	
	.NOTES
		Most of the code was copied from https://www.reddit.com/r/PowerShell/comments/8p09mb/how_to_loop_through_docker_ps_a_with_powershell/ so 
		credits go to reddit user /u/Lee_Dailey (https://www.reddit.com/user/Lee_Dailey/), a great contributor on the powershell subreddit [grin]

#>


# this presumes the source is outputting one string per line, not one multi-line string
$InStuff = $inStuff.Split("`n").Trim("`r")

foreach ($Index in 0..$InStuff.GetUpperBound(0))
    {
    # the 1st -replace handles the blank PORTS column
    $InStuff[$Index] = $InStuff[$Index] -replace '\s{23,}', ',,' -replace '\s{2,}', ','
    }

$DockerPSA_Objects = $InStuff |
    ConvertFrom-Csv

$DockerPSA_Objects


}