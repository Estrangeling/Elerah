function E-5 {
	param(
	[Parameter(ValueFromPipeline=$true)]
	[System.String]$String,
	[System.Double]$number
	)
	
	Process{
	$lt100 = @(
		[pscustomobject]@{Noun = 'Zero'; Value = 0}
		[pscustomobject]@{Noun = 'One'; Value = 1}
		[pscustomobject]@{Noun = 'Two'; Value = 2}
		[pscustomobject]@{Noun = 'Three'; Value = 3}
		[pscustomobject]@{Noun = 'Four'; Value = 4}
		[pscustomobject]@{Noun = 'Five'; Value = 5}
		[pscustomobject]@{Noun = 'Six'; Value = 6}
		[pscustomobject]@{Noun = 'Seven'; Value = 7}
		[pscustomobject]@{Noun = 'Eight'; Value = 8}
		[pscustomobject]@{Noun = 'Nine'; Value = 9}
		[pscustomobject]@{Noun = 'Ten'; Value = 10}
		[pscustomobject]@{Noun = 'Eleven'; Value = 11}
		[pscustomobject]@{Noun = 'Twelve'; Value = 12}
		[pscustomobject]@{Noun = 'Thirteen'; Value = 13}
		[pscustomobject]@{Noun = 'Fourteen'; Value = 14}
		[pscustomobject]@{Noun = 'Fifteen'; Value = 15}
		[pscustomobject]@{Noun = 'Sixteen'; Value = 16}
		[pscustomobject]@{Noun = 'Seventeen'; Value = 17}
		[pscustomobject]@{Noun = 'Eighteen'; Value = 18}
		[pscustomobject]@{Noun = 'Nineteen'; Value = 19}
		[pscustomobject]@{Noun = 'Twenty'; Value = 20}
		[pscustomobject]@{Noun = 'Thirty'; Value = 30}
		[pscustomobject]@{Noun = 'Forty'; Value = 40}
		[pscustomobject]@{Noun = 'Fifty'; Value = 50}
		[pscustomobject]@{Noun = 'Sixty'; Value = 60}
		[pscustomobject]@{Noun = 'Seventy'; Value = 70}
		[pscustomobject]@{Noun = 'Eighty'; Value = 80}
		[pscustomobject]@{Noun = 'Ninety'; Value = 90}
		)
	$gt100 = @(
		[pscustomobject]@{Noun = 'Thousand'; Value = 1000}
		[pscustomobject]@{Noun = 'Million'; Value = 1e6}
		[pscustomobject]@{Noun = 'Billion'; Value = 1e9}
		[pscustomobject]@{Noun = 'Trillion'; Value = 1e12}
		[pscustomobject]@{Noun = 'Quadrillion'; Value = 1e15}
		[pscustomobject]@{Noun = 'Quintillion'; Value = 1e18}
		[pscustomobject]@{Noun = 'Sextillion'; Value = 1e21}
		[pscustomobject]@{Noun = 'Septillion'; Value = 1e24}
		[pscustomobject]@{Noun = 'Octillion'; Value = 1e27}
		[pscustomobject]@{Noun = 'Nonillion'; Value = 1e30}
		[pscustomobject]@{Noun = 'Decillion'; Value = 1e33}
		[pscustomobject]@{Noun = 'Undecillion'; Value = 1e36}
		[pscustomobject]@{Noun = 'Duodecillion'; Value = 1e39}
		[pscustomobject]@{Noun = 'Tredecillion'; Value = 1e42}
		[pscustomobject]@{Noun = 'Quattuordecillion'; Value = 1e45}
		[pscustomobject]@{Noun = 'Quindecillion'; Value = 1e48}
		[pscustomobject]@{Noun = 'Sexdecillion'; Value = 1e51}
		[pscustomobject]@{Noun = 'Septendecillion'; Value = 1e54}
		[pscustomobject]@{Noun = 'Octodecillion'; Value = 1e57}
		[pscustomobject]@{Noun = 'Novemdecillion'; Value = 1e60}
		[pscustomobject]@{Noun = 'Vigintillion'; Value = 1e63}
		[pscustomobject]@{Noun = 'Googol'; Value = 1e100}
		[pscustomobject]@{Noun = 'Centillion'; Value = 1e303}
		)
		$number = 0
		$digit = 0
		[System.Boolean]$negative = $false
		[System.Boolean]$decimal = $false
		if ($String -match '\-| and ') { $string = $string -replace '\-| and ', ' '}
		if ($string -match ',') {$String = $String -Replace ','}
		if ($string.split( )[0] -eq "Negative") {
			$string = $string -replace "Negative "
			$negative = $true
		}
		if ($string.split( )[0] -in $gt100.Noun -or $string.split( )[0] -eq "Hundred") { $string = "one " + $string }
		$words = $String.Split(' ')
		for ($i = 0; $i -lt $words.count; $i++) {
			$word = $words[$i]
			if (-not $decimal) {
				if ($word -in $lt100.Noun){
					$digit += ($lt100 | Where {$_.Noun -eq $word}).value
				}
				elseif ($word -eq "Hundred" -and $digit -ne 0) {
					$digit *= 100
				}
				elseif ($word -in $gt100.Noun) {
					$number += $digit * ($gt100 | Where {$_.Noun -eq $word}).value
					$digit = 0
				}
			}
			if ($word -eq "point") {
				$decimal = $true
				$point = $i
			}
			if ($decimal -and $word -in $lt100.Noun) {
				$number += ($lt100 | Where {$_.Noun -eq $word}).value * [math]::pow(10, -($i - $point))
			}
		}
		$number = $number + $digit
	if ($negative) {$number = -$number}
	Write-Host "$number"
	}
}
$string = $Args[0]
E-5 $string