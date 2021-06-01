function Chi-Ra {
param(
[Parameter(ValueFromPipeline=$true)]
[System.String]$String,
[System.Int64]$h,
[System.Int64]$l,
[System.Int64]$i
)
$h=$string.Split(",")[0]
$l=$string.Split(",")[1]
$answerable=$false
if ($l -gt 4*$h -or $l -lt 2*$h) {return "No Solution"}
	else{
		for ($i=0;$i -le $h;$i++){
			$r=$h-$i
			if (2*$i+4*$r -eq $l) {
				Write-Host "There are $i chicken and $r rabbits"
				$answerable=$true
				break
			}
		}
	}
	if ($answerable -eq $false) {return "No Solution"}
}