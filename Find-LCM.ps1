Function Find-LCM([string]$string) {
	$factors = @()
	$numbers = $string.Split(",")
	foreach ($n in $numbers) {
		$c = 0
		while ( ($n % 2) -eq 0) {
			$c += 1
			$n = $n / 2
			if (($factors | Where {$_ -eq 2}).count -lt $c) { $factors += 2 }
		}
		$c = 0
		$f = 3
		while ($f -le [int][math]::sqrt($n)) {
			while ( ($n % $f) -eq 0) {
				$c += 1
				$n = $n / $f
				if (($factors | Where {$_ -eq $f}).count -lt $c) { $factors += $f }
			}			
			$f += 2
			$c = 0
		}
		if ($n -notin $factors) { $factors += $n }
	}
	[Double]$p = 1
	foreach($f in $factors) {$p = $p * $f}
	$p
}

$string = $Args[0]
Find-LCM $string