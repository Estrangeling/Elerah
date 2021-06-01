function NumConversion {

	param(
		[parameter(valuefrompipeline=$true, mandatory=$true, position=0)] [ValidateNotNullOrEmpty()] [string] $data,
		[parameter(valuefrompipeline=$true, mandatory=$true, position=1)] [ValidateNotNullOrEmpty()] [string] $task
	)
	
	begin {
		
		$dict = @(
			[PSCustomObject]@{bin = '0000'; dec = 0; hex = '0' }
			[PSCustomObject]@{bin = '0001'; dec = 1; hex = '1' }
			[PSCustomObject]@{bin = '0010'; dec = 2; hex = '2' }
			[PSCustomObject]@{bin = '0011'; dec = 3; hex = '3' }
			[PSCustomObject]@{bin = '0100'; dec = 4; hex = '4' }
			[PSCustomObject]@{bin = '0101'; dec = 5; hex = '5' }
			[PSCustomObject]@{bin = '0110'; dec = 6; hex = '6' }
			[PSCustomObject]@{bin = '0111'; dec = 7; hex = '7' }
			[PSCustomObject]@{bin = '1000'; dec = 8; hex = '8' }
			[PSCustomObject]@{bin = '1001'; dec = 9; hex = '9' }
			[PSCustomObject]@{bin = '1010'; dec = 10; hex = 'a'}
			[PSCustomObject]@{bin = '1011'; dec = 11; hex = 'b'}
			[PSCustomObject]@{bin = '1100'; dec = 12; hex = 'c'}
			[PSCustomObject]@{bin = '1101'; dec = 13; hex = 'd'}
			[PSCustomObject]@{bin = '1110'; dec = 14; hex = 'e'}
			[PSCustomObject]@{bin = '1111'; dec = 15; hex = 'f'}
		)
		
		$type = @(
			[PSCustomObject]@{name = 'binary number'; max = '11111111111111111111111111111111'}
			[PSCustomObject]@{name = 'decimal natural number'; max = 4294967295}
			[PSCustomObject]@{name = 'hexadecimal number'; max = 'ffffffff'}
			[PSCustomObject]@{name = 'IPv4 address'; max = '255.255.255.255'}
		)
		
		$err = @(
			"InvalidData: The inputted string isn't a valid {0}, process will now stop."
			"LimitsExceeded: The value of the inputted {0} exceeds the maximum IPv4 value possible, process will now stop.(maximum value allowed: {1})"
		)
	}
	
	process {
		
		$binsub = {
			
			param($bin, $task)
	
			[string]$bin = $bin
			
			if ($bin -match "[01]{$($bin.length)}") {
				switch ($task)
				{
				'd' {
						$power = 1
						$dec = 0
						[int[]]$bits = $bin -split "(0|1)" | where {$_ -ne ''}
						for ($i = $bits.count - 1; $i -ge 0; $i--) {
							$bit = $bits[$i]
							$dec += $bit * $power
							$power *= 2
						}
						$dec
					}
				
				'h' {
						$i = 0
						if ($bin.Length % 4 -ne 0) {
							while ($i -lt $bin.Length) {$i += 4}
							$bin = '0' * ($i - $bin.Length) + $bin
						}
						[array]$bin = $bin -split '([01]{4})' | where {$_ -ne ''}
						$hex = foreach ($seg in $bin) { ($dict | where {$_.bin -eq $seg}).hex }
						$hex = $hex -join ''
						$hex
					}
					
				'i' {
						if ($bin -match "^[01]{1,32}$") {
							if ($bin.length -lt 32) { $bin = '0' * (32 - $bin.length) + $bin }
							[array]$bin = $bin -split '([01]{8})' | where {$_ -ne ''}
							[array]$ip = foreach($seg in $bin) { &$binsub -bin $seg -task 'd' }
							$ip = $ip -join '.'
							$ip
						} else { write-error -message $($err[1] -f $type[0].name, $type[0].max) -Category LimitsExceeded; break }
					}
				}
				
			} else { write-error -message $($err[0] -f $type[0].name) -Category InvalidData; break }
		}

		$decsub = {
		
			param($dec, $task)
			
			if ([string]$dec -match "[0-9]{$($([string]$dec).Length)}") {
				[double]$dec = $dec
				switch ($task)
				{
				'b'	{
						[array]$bits = for ($i = 1; $i -le $dec; $i*=2) {$i}
						[string[]]$bin = for($i = $bits.count - 1; $i -ge 0; $i--) {
							$bit = $bits[$i]
							if ($dec -ge [double]$bit) {1; $dec -= $bit}
							else {0}
						}
						[string]$bin = $bin -join ''
						$bin
					}
				
				'h'	{
						[array]$bits = for ($i = 1; $i -le $dec; $i *= 16) {$i}
						[string[]]$hex = for ($i = $bits.count - 1; $i -ge 0; $i--) {
							$bit = $bits[$i]
							if ($dec -ge $bit) {
								$num = [math]::floor($dec / $bit)
								$dec = $dec % $bit
								($dict | where {$_.dec -eq [string]$num}).hex
							}
							else {0}
						}
						[string]$hex = $hex -join ''
						$hex
					}
				
				'i' {
						if ($dec -le 4294967295) {
							[array]$ip = for ($i = 0; $i -le 3; $i++) {
								$seg = $dec % 256
								$dec = ($dec - $seg) / 256
								$seg
							}
							$ip = for ($i = 3; $i -ge 0; $i--) { $ip[$i] }
							$ip = $ip -join '.'
							$ip
						} else { write-error -message $($err[1] -f $type[1].name, $type[1].max) -Category LimitsExceeded; break }
				
					}
				}
				
			} else { write-error -message $($err[0] -f $type[1].name) -Category InvalidData; break }
		}
		
		$hexsub = {
		
			param($hex, $task)
			
			[string]$hex = $hex
			if ($hex -match "[0-9a-f]{$($hex.length)}") {
				switch ($task)
				{
				'b' {
						[array]$hexa = $hex -split '(\w{1})' | where {$_ -ne ''}
						$bin = for ($i = 0; $i -lt $hexa.count; $i++) {
							($dict | where {$_.hex -eq $hexa[$i]}).bin
						}
						$bin = $bin -join ''
						$bin
					}
					
				'd' {
						[array]$bits = for($i = 0; $i -lt $hex.length; $i++){[math]::pow(16, $i)}
						$dec = 0
						[array]$hexa = $hex -split '(\w{1})' | where {$_ -ne ''}
						for (($i = 0), ($j = $hexa.count - 1); $i -lt $hexa.count; $i++, $j--) {
							$num = [double]($dict | where {$_.hex -eq $hexa[$j]}).dec
							$bit = $bits[$i]
							$dec = $dec + $num * $bit
						}
						$dec
					}
					
				'i'	{
						if ($hex -match "^[0-9a-f]{1,8}$") {
							if ($hex.length -lt 8) {$hex = '0' * (8 - $hex.length) + $hex }
							[array]$hexa = $hex -split '(\w{2})' | where {$_ -ne ''}
							[array]$ip = foreach($seg in $hexa) { &$hexsub -hex $seg -task 'd'}
							$ip = $ip -join '.'
							$ip
						} else { write-error -message $($err[1] -f $type[2].name, $type[2].max) -Category LimitsExceeded; break }
					}
				}
				
			} else { write-error -message $($err[0] -f $type[2].name) -Category InvalidData; break }
		}
		
		$ipsub = {
		
			param($ip, $task)
			
			[string]$ip = $ip
			if ($ip -match '^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$') {
				[array]$ip = $ip.split('.')
				switch ($task)
				{
				'b'	{
						[array]$bin = foreach ($seg in $ip) {
							[int]$num = $seg
							[array]$bits = for ($i = 128; $i -ge 1; $i /= 2) {$i}
							$bits = $bits | % {
								if ($num -ge [int64]$_) {1; $num -= $_}
								else {0} 
							}
							[string]$bits = $bits -join ''
							$bits
						}
						$bin = $bin -join ''
						$bin
					}
					
				'd' {
						$dec = 0
						$base = 16777216
						foreach ($seg in $ip) {
							$dec += [int]$seg * $base
							$base = $base / 256
						}
						$dec
					}
				
				'h' {
						[string[]]$hex = foreach ($seg in $ip) {
							$byte = &$decsub -dec $seg -task 'h'
							if ($byte.length -lt 2) { $byte = '0' + $byte }
							$byte
						}
						$hex = $hex -join ''
						$hex
					}
				}
				
			} else { write-error -message $($err[0] -f $type[3].name) -Category InvalidData; break }
		}
		
		switch ($task)
		{
			'bd' { &$binsub -bin $data -task 'd'}
			'bh' { &$binsub -bin $data -task 'h'}
			'bi' { &$binsub -bin $data -task 'i'}
			'db' { &$decsub -dec $data -task 'b'}
			'dh' { &$decsub -dec $data -task 'h'}
			'di' { &$decsub -dec $data -task 'i'}
			'hb' { &$hexsub -hex $data -task 'b'}
			'hd' { &$hexsub -hex $data -task 'd'}
			'hi' { &$hexsub -hex $data -task 'i'}
			'ib' { &$ipsub -ip $data -task 'b'}
			'id' { &$ipsub -ip $data -task 'd'}
			'ih' { &$ipsub -ip $data -task 'h'}
			default {write-error -message "InvalidOperation: The operation specified is undefined, process will now stop." -Category InvalidOperation}
		}
	}
}
$data = $Args[0]
$task = $Args[1]
NumConversion $data $task