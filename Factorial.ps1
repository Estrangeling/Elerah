function factorial($n) {
	$f = 1
	for ($i = 1; $i -le $n; $i++){ $f = $f * $i; $f }
}

$n = $Args[0]
factorial $n