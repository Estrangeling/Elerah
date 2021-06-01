function sum-fac {
	PARAM (
		[Parameter(ValueFromPipeline=$true)]
		[System.Int32]$n,
		[System.Int32]$i,
		[System.Double]$f
	)
	Process {
		$f=1
		[System.Double]$s=0
		for ($i=1;$i -le $n;$i++){
			$f=$f*$i
			$s+=$f
			$s
		}
	}
}