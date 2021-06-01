$months=@(
[PSCustomObject]@{Month='January';Days=31}
[PSCustomObject]@{Month='February';Days=28}
[PSCustomObject]@{Month='March';Days=31}
[PSCustomObject]@{Month='April';Days=30}
[PSCustomObject]@{Month='May';Days=31}
[PSCustomObject]@{Month='June';Days=30}
[PSCustomObject]@{Month='July';Days=31}
[PSCustomObject]@{Month='August';Days=31}
[PSCustomObject]@{Month='September';Days=30}
[PSCustomObject]@{Month='October';Days=31}
[PSCustomObject]@{Month='November';Days=30}
[PSCustomObject]@{Month='December';Days=31}
)
function BlackFriday {
	param(
	[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)] [int64] $start,
	[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=1)] [int64] $end
	)
	$years=$start..$end
	$blackfriday=@()
	foreach ($year in $years) {
		$array=1..12
		foreach ($arra in $array) {
			$month=0
			for ($i=0;$i -lt $arra-1;$i++) {
				$month+=$months[$i].Days
			}
			[int]$ye=$year
			if ($arra -le 2) { $ye-=1}
			if ($ye % 4 -eq 0) {$leap=$ye/4}
			else {while ($ye % 4 -ne 0) {$ye-=1}
			$leap=$ye/4}
			if ($ye % 100 -eq 0) {$century=$ye/100}
			else {while ($ye % 100 -ne 0) {$ye-=4}
			$century=$ye/100}
			if ($ye % 400 -eq 0) {$cycle=$ye/400}
			else {while ($ye % 400 -ne 0) {$ye-=100}
			$cycle=$ye/400}
			$leap=$leap-$century+$cycle
			$date=[int64](($year-1)*365+$month+13+$leap)
			if ($date % 7 -eq 5) {
				$name=$months[$arra-1].Month
				$blackfriday+=[string]"$year, $name 13, Friday"
			}
		}
	}
	$blackfriday
}
$start=Read-Host "Input start year"
$end=Read-Host "Input end year"
BlackFriday $start $end