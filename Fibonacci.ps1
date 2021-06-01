function Fibonacci {
Param(
	[Parameter(ValueFromPipeline=$true)]
	[System.Int64]$n,
	[System.Double]$a,
	[System.Double]$b,
	[System.Double]$c
	)
	Process{
		$a=1
		$b=1
		$c=0
		for($i=1;$i -le $n;$i++){
			$c=$a
			$a=$b
			$b+=$c
			$c
		}
	}
}