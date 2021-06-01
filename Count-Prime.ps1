function Count-Prime {
	param(
		[Parameter(ValueFromPipeline=$true)]
		$range
    )
	
	Process {
		$array = [int[]]$(0..$range)
		$PriNum = @()
		foreach($arra in $array){
			$number = $arra
			$prime = $true;
			if ($number -isnot [int]) {$prime = $false}
			elseif ($number -le 0) {$prime = $false}
			else {
				if ($number -eq 1) {
					$prime = $false;
				}
				if ($number -gt 3) {
					$sqrt = [math]::Sqrt($number); 
					if ($sqrt -is [int]) {$prime = $false}
					else {
						for($i = 2; $i -le [int]$sqrt; $i++) {
							if ($number % $i -eq 0) {
								$prime = $false;
								break;
							}
						}
					}
				}
			}
			if ($prime){$PriNum += $number}
		}
	$PriNum.count
	}
}

$range = $Args[0]
Count-Prime $range