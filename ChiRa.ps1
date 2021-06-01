function ChiRa {
param(
[Parameter(ValueFromPipeline=$true)]
[System.String]$String,
[System.Int32]$h,
[System.Int32]$l,
[System.Int32]$x,
[System.Int32]$y
)
$h=$string.Split(",")[0]
$l=$string.Split(",")[1]
$answerable=$false
if ($l -gt 4*$h -or $l -lt 2*$h) {return "No Solution"}
	else{
			$z = (4*$h - $l)/2
			if ($z -is [int] -and $z -gt 0) {
				$x=$z
				$y=$h -$x
				Write-Host "There are $x chicken and $y rabbits"
				$answerable=$true
			}
		}
	if ($answerable -eq $false) {return "No Solution"}
}