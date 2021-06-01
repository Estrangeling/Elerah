	function Sort-Num {
	 PARAM (
			[Parameter(ValueFromPipeline=$true)]
			[System.String]$String
			)
		Process {
			$array = $String.Split( )
			$padnum = @()
			$sorted = @()
			$numbers = @()
			$length=0
			foreach ($arra in $array) {
				while ($arra.Length -gt $length) {
				$length=$arra.Length
				}
			}
			foreach ($arra in $array) {
				$padded = "{0:D$length}" -f [int64]$arra
				$padnum +=$padded
			}
			$sorted = $padnum | Sort-Object
			foreach ($sorte in $sorted) {
				$number=[int64]$sorte
				$numbers+=$number
			}
			$numbers
		}
	}