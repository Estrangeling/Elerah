	$Cultures = @(
	[PSCustomObject]@{Format = 'yyyy-MM-dd'; 	Delimiter = '-'; Indices = (0, 1, 2); Regex = '^\d{4}\-0?([2-9]|1[0-2]?)\-(0?(3[01]|[12][0-9]|[1-9]))$' }
	[PSCustomObject]@{Format = 'yyyy/MM/dd'; 	Delimiter = '/'; Indices = (0, 1, 2); Regex = '^\d{4}\/0?([2-9]|1[0-2]?)\/(0?(3[01]|[12][0-9]|[1-9]))$' }
	[PSCustomObject]@{Format = 'MM/dd/yyyy'; 	Delimiter = '/'; Indices = (2, 0, 1); Regex = '^0?([2-9]|1[0-2]?)\/(0?(3[01]|[12][0-9]|[1-9]))\/\d{4}$' }
	[PSCustomObject]@{Format = 'MMM dd, yyyy'; 	Delimiter = ' '; Indices = (2, 0, 1); Regex = '^[A-Za-z]{3} (0?(3[01]|[12][0-9]|[1-9])), \d{4}$' }
	[PSCustomObject]@{Format = 'dd MMM, yyyy'; 	Delimiter = ' '; Indices = (2, 1, 0); Regex = '^(0?(3[01]|[12][0-9]|[1-9])) [A-Za-z]{3}, \d{4}$' }
	[PSCustomObject]@{Format = 'MMMM dd, yyyy'; Delimiter = ' '; Indices = (2, 0, 1); Regex = '^[A-Za-z]{3,9} (0?(3[01]|[12][0-9]|[1-9])), \d{4}$' }
	[PSCustomObject]@{Format = 'dd MMMM, yyyy'; Delimiter = ' '; Indices = (2, 1, 0); Regex = '^(0?(3[01]|[12][0-9]|[1-9])) [A-Za-z]{3,9}, \d{4}$' }
	[PSCustomObject]@{Format = 'yyyy, MMM dd'; 	Delimiter = ' '; Indices = (0, 1, 2); Regex = '^\d{4}, [A-Za-z]{3} (0?(3[01]|[12][0-9]|[1-9]))$' }
	[PSCustomObject]@{Format = 'yyyy, MMMM dd'; Delimiter = ' '; Indices = (0, 1, 2); Regex = '^\d{4}, [A-Za-z]{3,9} (0?(3[01]|[12][0-9]|[1-9]))$' }
	)

	$months = @(
	[PSCustomObject]@{Month = 'January'; 	Days = 31; Number = 1}
	[PSCustomObject]@{Month = 'February'; 	Days = 28; Number = 2}
	[PSCustomObject]@{Month = 'March'; 		Days = 31; Number = 3}
	[PSCustomObject]@{Month = 'April'; 		Days = 30; Number = 4}
	[PSCustomObject]@{Month = 'May'; 		Days = 31; Number = 5}
	[PSCustomObject]@{Month = 'June'; 		Days = 30; Number = 6}
	[PSCustomObject]@{Month = 'July'; 		Days = 31; Number = 7}
	[PSCustomObject]@{Month = 'August'; 	Days = 31; Number = 8}
	[PSCustomObject]@{Month = 'September'; 	Days = 30; Number = 9}
	[PSCustomObject]@{Month = 'October'; 	Days = 31; Number = 10}
	[PSCustomObject]@{Month = 'November'; 	Days = 30; Number = 11}
	[PSCustomObject]@{Month = 'December'; 	Days = 31; Number = 12}
	)
	function ParseDate {
		Param(
			[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)] $date
		)
		foreach ($Culture in $Cultures) {
			if ($date -match $Culture.Regex){
				$date = $date.replace(',', '').split($Culture.Delimiter)
				$Year = [int]$Date[$Culture.Indices[0]]
				$Month = $Date[$Culture.Indices[1]]
				if ($Month -notmatch "^\d+$") {
					foreach ($m in $Months) {
						if ($m.Month -like "$Month*") {
							$Month = $m.Number
						}
					}
				}
                $Month = [int]$Month
				$Day = [int]$Date[$Culture.Indices[2]]
			}
		}
		[PSCustomObject]@{Year = $Year; Month = $Month; Day = $Day}
	}

	function TotalDays {
		param (
		[Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)] $date
		)
		
		$year = $date.year
		$ye = $year
		$month = $date.month
		$day = $date.day
		if ($month -le 2) {$ye -= 1}
		$leaps = [math]::floor($ye / 4) - [math]::floor($ye / 100) + [math]::floor($ye / 400)
		$m = 0
		for ($i = 0; $i -lt $month - 1; $i++) {$m += $months[$i].days}
		$days = ($year - 1) * 365 + $m + $day + $leaps
		$days
	}
	function Diff-Date {
		PARAM(
			[Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 0)] $date1, 
			[Parameter(ValueFromPipeline = $true, Mandatory = $true, Position = 1)] $date2
			)
			
		$days1 = TotalDays $(ParseDate $date1)
		$days2 = TotalDays $(ParseDate $date2)
		$diffdate = $days2 - $days1
		return $diffdate
	}
	$date1 = $Args[0]
	if (-not $date1) {
		$date1 = "1999-04-10"
	}
	$date2 = $Args[1]
	if (-not $date2) {
		$date2 = (Get-Date -DisplayHint Date -Format "yyyy-MM-dd" | Out-String).TrimEnd()
	}
	Write-Host "Start:${date1}, End:${date2}"
	Diff-Date $date1 $date2