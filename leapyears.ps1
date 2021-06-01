function leapyears {
	param(
		[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)] [int64] $start,
		[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=1)] [int64] $end
	)
	$years=$start..$end
	$leapyears=@()
	foreach ($year in $years) {
	$leap=$false
	if ($year % 4 -eq 0 -and $year % 100 -ne 0) {$leap=$true}
	elseif ($year % 400 -eq 0) {$leap=$true}
	if ($leap -eq $true) {$leapyears+=$year}
	}
	$leapyears
}
$start=Read-Host "Input start year"
if (-not $start) {$start=1}
$end=Read-Host "Input end year"
leapyears $start $end