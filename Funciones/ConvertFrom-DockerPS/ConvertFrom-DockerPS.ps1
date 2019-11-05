function ConvertFrom-DockerPS {
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
		The core of the code was taken from https://www.reddit.com/r/PowerShell/comments/8p09mb/how_to_loop_through_docker_ps_a_with_powershell/ so 
		credits go to reddit user /u/Lee_Dailey (https://www.reddit.com/user/Lee_Dailey/), a great contributor on the powershell subreddit [grin]
		I've also (forcefully) learned the how's and why's of using advanced functions, and the massive value of the ISE (which i will never use again, heh)
		Thank you fellow admin for reading this ramblings, and party on!

#>
	[CmdletBinding()]
	
	param(
		[Parameter(ValueFromPipeline=$true)]$adentro
	)
		
	begin{
		#Declare the $final helper object
		$final=@()
	}

	process{
		$InStuff = $adentro.Split("`n").Trim("`r")
		$OutStuff = $InStuff -replace '\s{23,}', ',,' -replace '\s{2,}', ','
		#Added this to mitigate an issue with formatting on the ugly header
		if ($OutStuff -like "*IMAGE,COMMAND,*") { $OutStuff= $OutStuff.replace(',,',',')}
        $final+=$OutStuff
	}

	end{
		#Convert it all to CSV and send it back
		$final | ConvertFrom-Csv  
	}
}
