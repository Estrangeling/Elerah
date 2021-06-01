function Str-Num {
	param(
	[Parameter(ValueFromPipeline=$true)]
	[System.String]$String,
	[System.Double]$number,
	[System.Double]$digit
	)
	
	Process{
	$lt100 = @{
		'Oh'=0
		'Zero'=0
		'One'=1
		'Two'=2
		'Three'=3
		'Four'=4
		'Five'=5
		'Six'=6
		'Seven'=7
		'Eight'=8
		'Nine'=9
		'Ten'=10
		'Eleven'=11
		'Twelve'=12
		'Thirteen'=13
		'Fourteen'=14
		'Fifteen'=15
		'Sixteen'=16
		'Seventeen'=17
		'Eighteen'=18
		'Nineteen'=19
		'Twenty'=20
		'Thirty'=30
		'Forty'=40
		'Fifty'=50
		'Sixty'=60
		'Seventy'=70
		'Eighty'=80
		'Ninety'=90
		}
	$gt100 =@{
		'Thousand'=1e3
		'Million'=1e6
		'Billion'=1e9
		'Trillion'=1e12
		'Quadrillion'=1e15
		'Quintillion'=1e18
		'Sextillion'=1e21
		'Septillion'=1e24
		'Octillion'=1e27
		'Nonillion'=1e30
		'Decillion'=1e33
		'Undecillion'=1e36
		'Duodecillion'=1e39
		'Tredecillion'=1e42
		'Quattuordecillion'=1e45
		'Quindecillion'=1e48
		'Sexdecillion'=1e51
		'Septendecillion'=1e54
		'Octodecillion'=1e57
		'Novemdecillion'=1e60
		'Vigintillion'=1e63
		'Googol'=1e100
		'Centillion'=1e303
		}
		$number=0
		$digit=0
		[System.Boolean]$negative=$false
		[System.Boolean]$decimal=$false
		[System.Boolean]$invalid=$false
		if ($string -match '\-') {$string = $string -replace "-", " "}
		if ($string -match ' and ') {$string = $string -replace " and ", " "}
		if ($string.split( )[0] -eq "Negative") {
			$string = $string -replace "Negative "
			$negative=$true
		}
		if ($gt100.Keys -contains($string.split( )[0]) -or $string.split( )[0] -eq "Hundred") { $string = "one " + $string}
		$count = $string.split( ).count
		if ($count -eq 2 -or $count -eq 3 -or $count -eq 4){
			$n=0
			$array = $string.split( )
			foreach ($arra in $array){
				if ($lt100.Keys -contains($arra)){
				$n+=1
				}
			}
			if ($n -eq $count) {
				if ($count -eq 2) {
					if ($lt100.($string.split( )[0]) -lt 20 -or $lt100.($string.split( )[1]) -ge 10){
						$fault=$string
						$string=$string.split( )[0]+" Hundred "+$string.split( )[1]
						$invalid=$true
					}
				}
				elseif ($count -eq 3 -or $count -eq 4) {
					$fault=$string
					$invalid=$true
					if ($count -eq 3){
						$string=$string.split( )[0]+" Hundred "+$string.split( )[1]+" "+$string.split( )[2]
					}
					elseif ($count -eq 4) {
						if ($lt100.($string.split( )[0]) -ge 20){
						$string=$string.split( )[0]+" "+$string.split( )[1]+" Hundred "+$string.split( )[2]+" "+$string.split( )[3]
						}
						elseif ($lt100.($string.split( )[0]) -lt 10){
							$string=$string.split( )[0]+" Thousand "+$string.split( )[1]+" "+$string.split( )[2]+" "+$string.split( )[3]
						}
					}
				}
				if ($invalid -eq $true) {
					Write-Warning "Invalid expression detected, $fault is not a valid expression for numbers, it has been recognized as an English informal way to pronounce years;$fault has been adjusted to this valid expression: $string so this program can process it."
				}
			}
		}
		$count = $string.split( ).count
		for ($i=0;$i -lt $count;$i++) {
			$word = $string.split( )[$i]
			if ($decimal -eq $false) {
				if ($lt100.Keys -contains($word)){
					$digit+=$lt100.$word
				}
				elseif ($word -eq "Hundred" -and $digit -ne 0) {
					$digit*=100
				}
				elseif ($gt100.Keys -contains($word)) {
					$number+=$digit*$gt100.$word
					$digit=0
				}
			}
			if ($word -eq "point") {
				$decimal = $true
				$point=$i
			}
			if ($decimal -eq $true -and $lt100.Keys -contains $word) {
				$number+=$lt100.$word * [math]::pow(10,-($i-$point))
			}
		}
		$number=$number+$digit
	if ($negative -eq $true) {$number=-$number}
	Return "$number"
	}
}
$string = Read-Host "Please input string"
Str-Num $string