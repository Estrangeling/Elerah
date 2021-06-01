Function Factorise {
    PARAM ([System.Double]$Number)
	if ($number -lt 2) {	Write-Error -Message "Number to be factorised must be greater than or equal to 2, the script will exit now"}
	else {
	$sqrt=[math]::sqrt($number)
	$Factor=2
    while ( ($Number % $Factor) -eq 0) {
        $Factor
        $Number=$Number/$Factor
    }
	$Factor=3
    while ($Factor -le $sqrt) {
        while ( ($Number % $Factor) -eq 0) {
            $Factor
            $Number=$Number/$Factor
        }
        $Factor+=2
    }
    if ($Number -gt 1) {$Number}
	}
}
$number = Read-Host "Input number to be factorised"
Factorise $number