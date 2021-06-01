	$Culture=@(
	[PSCustomObject]@{Format='yyyy-MM-dd';Regex='\d{4}\-0?([2-9]|1[0-2]?)\-(0?(3[01]|[12][0-9]|[1-9]))'}
	[PSCustomObject]@{Format='yyyy/MM/dd';Regex='\d{4}\/0?([2-9]|1[0-2]?)\/(0?(3[01]|[12][0-9]|[1-9]))'}
	[PSCustomObject]@{Format='MM/dd/yyyy';Regex='0?([2-9]|1[0-2]?)\/(0?(3[01]|[12][0-9]|[1-9]))\/\d{4}'}
	[PSCustomObject]@{Format='MMM dd, yyyy';Regex='[A-Za-z]{3} (0?(3[01]|[12][0-9]|[1-9])), \d{4}'}
	[PSCustomObject]@{Format='dd MMM, yyyy';Regex='(0?(3[01]|[12][0-9]|[1-9])) [A-Za-z]{3}, \d{4}'}
	[PSCustomObject]@{Format='MMMM dd, yyyy';Regex='[A-Za-z]{3,9} (0?(3[01]|[12][0-9]|[1-9])), \d{4}'}
	[PSCustomObject]@{Format='dd MMMM, yyyy';Regex='(0?(3[01]|[12][0-9]|[1-9])) [A-Za-z]{3,9}, \d{4}'}
	[PSCustomObject]@{Format='yyyy, MMM dd';Regex='\d{4}, [A-Za-z]{3} (0?(3[01]|[12][0-9]|[1-9]))'}
	[PSCustomObject]@{Format='yyyy, MMMM dd';Regex='\d{4}, [A-Za-z]{3,9} (0?(3[01]|[12][0-9]|[1-9]))'}
	)

	$months=@(
	[PSCustomObject]@{Month='January';Days=31;Number=1}
	[PSCustomObject]@{Month='February';Days=28;Number=2}
	[PSCustomObject]@{Month='March';Days=31;Number=3}
	[PSCustomObject]@{Month='April';Days=30;Number=4}
	[PSCustomObject]@{Month='May';Days=31;Number=5}
	[PSCustomObject]@{Month='June';Days=30;Number=6}
	[PSCustomObject]@{Month='July';Days=31;Number=7}
	[PSCustomObject]@{Month='August';Days=31;Number=8}
	[PSCustomObject]@{Month='September';Days=30;Number=9}
	[PSCustomObject]@{Month='October';Days=31;Number=10}
	[PSCustomObject]@{Month='November';Days=30;Number=11}
	[PSCustomObject]@{Month='December';Days=31;Number=12}
	)

	function Identify {
		PARAM (
			[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)] [System.String] $string, 
			[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=1)] [System.String] $regex
			)
			$string -eq ($string| Select-String -pattern $regex).matches.value
		}
		
	function Leapdays {
		PARAM (
			[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)] $date
			)
			Process {
				[int]$years=$date.year
				if ($date.month -le 2) { $years-=1}
				if ($years % 4 -eq 0) {$leap=$years/4}
				else {while ($years % 4 -ne 0) {$years-=1}
				$leap=$years/4}
				if ($years % 100 -eq 0) {$century=$years/100}
				else {while ($years % 100 -ne 0) {$years-=4}
				$century=$years/100}
				if ($years % 400 -eq 0) {$cycle=$years/400}
				else {while ($years % 400 -ne 0) {$years-=100}
				$cycle=$years/400}
				$leap=$leap-$century+$cycle
				$leap
			}
		}
		
	function ParseDate {
		Param(
		[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)] $string,
		[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=1)] $format
		)
		
		if ($format -eq 'yyyy-MM-dd'){
		$Year=$string.Split("-")[0] -as [int]
		$Month=$string.Split("-")[1] -as [int]
		$Day=$string.Split("-")[2] -as [int]
		}
		elseif ($format -eq 'yyyy/MM/dd'){
		$Year=$string.Split("/")[0]  -as [int]
		$Month=$string.Split("/")[1]  -as [int]
		$Day=$string.Split("/")[2] -as [int]
		}
		elseif ($format -eq 'MM/dd/yyyy'){
		$Year=$string.Split("/")[2] -as [int]
		$Month=$string.Split("/")[0] -as [int]
		$Day=$string.Split("/")[1] -as [int]
		}
		elseif ($format -eq 'MMM dd, yyyy'){
		$string=$string -replace ","
		$Year=$string.Split( )[2] -as [int]
		$Month=($months | Where-Object{$_.Month -like $string.split( )[0]+"*"}).number -as [int]
		$Day=$string.Split( )[1] -as [int]
		}
		elseif ($format -eq 'dd MMM, yyyy'){
		$string=$string -replace ","
		$Year=$string.Split( )[2] -as [int]
		$Month=($months | Where-Object{$_.Month -like $string.split( )[1]+"*"}).number -as [int]
		$Day=$string.Split( )[0] -as [int]
		}
		elseif ($format -eq 'MMMM dd, yyyy'){
		$string=$string -replace ","
		$Year=$string.Split( )[2] -as [int]
		$Month=($months | Where-Object{$_.Month -eq $string.split( )[0]}).number -as [int]
		$Day=$string.Split( )[1] -as [int]
		}
		elseif ($format -eq 'dd MMMM, yyyy'){
		$string=$string -replace ","
		$Year=$string.Split( )[2] -as [int]
		$Month=($months | Where-Object{$_.Month -eq $string.split( )[1]}).number -as [int]
		$Day=$string.Split( )[0] -as [int]
		}
		elseif ($format -eq 'yyyy, MMM dd'){
		$string=$string -replace ","
		$Year=$string.Split( )[0] -as [int]
		$Month=($months | Where-Object{$_.Month -like $string.split( )[1]+"*"}).number -as[int]
		$Day=$string.Split( )[2] -as [int]
		}
		elseif ($format -eq 'yyyy, MMMM dd'){
		$string=$string -replace ","
		$Year=$string.Split( )[0] -as [int]
		$Month=($months | Where-Object{$_.Month -eq $string.split( )[1]}).number -as [int]
		$Day=$string.Split( )[2] -as [int]
		}
		[PSCustomObject]@{Year=$Year;Month=$Month;Day=$Day}
		}

	function Date-Days {
		PARAM(
			[Parameter(ValueFromPipeline=$true, Mandatory=$true)] $date
			)
			for ($i=0;$i -lt $Culture.count;$i++) {
			if (Identify $date $Culture[$i].Regex) {
				$date=ParseDate $date $Culture[$i].Format
				break
			}
		}
		$month=0
		for ($i=0;$i -lt $date.month-1;$i++) {
			$month+=$months[$i].Days
		}
		$totaldays=($date.year-1)*365+$(Leapdays $date)+$month+$date.day
		return $totaldays
	}
	$date=Read-Host "Input Date to Convert"
	Write-Host $date
	Date-Days $date