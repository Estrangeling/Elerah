function ltTriNum {
	param(
		[Parameter(ValueFromPipeline=$true)]
		[System.Double]$a,
		[System.Double]$t
	)
for ($i=1;$i -le $a;$i++){
	$t=([math]::pow($i,2)-$i)/2
	$t
	}
}