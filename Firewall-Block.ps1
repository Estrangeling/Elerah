Function Firewall-Block {

	Param(
		[Parameter(ValueFromPipeline=$true, Mandatory=$true)] $path
	)
	
	Switch ($path -match '\|')
	{
		$true { $execs = $path.Split('|') }
		$false { if (Test-Path $path -PathType Container) {
			$execs = (Get-ChildItem -Path $path -File -Filter '*.exe' -Force -Recurse).FullName
			} else { $execs = $path }
		}
	}
	Foreach ($exec in $execs) {
		$name = Split-Path -Path $exec -Leaf
		netsh advfirewall firewall add rule name="Block_$name" dir=in action=block program="$exec" enable=yes
		netsh advfirewall firewall add rule name="Block_$name" dir=out action=block program="$exec" enable=yes
	}
}
$path = $args[0]
Firewall-Block $path
