function Calc-Pi {
param(
[Parameter(ValueFromPipeline=$true)]
[System.Int32]$n
)

process {
	$a=0
	$array=[int]-$n..$n
	foreach ($arra in $array) {
		$x=$arra
		foreach ($arra in $array) {
		$y=$arra
		if ([math]::sqrt($x*$x+$y*$y) -le $n) {$a+=1}
		}
	}
	$pi=$a/($n*$n)
	return $pi
	}
}