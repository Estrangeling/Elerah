$start=Read-Host "Input start year"
$end=Read-Host "Input end year"
$years=$start..$end
$blackfriday=@()
foreach ($year in $years) {
	$blackfriday+=1..12 | foreach { [datetime]"$year-$_-13" } | where { $_.DayOfWeek -eq 'Friday'} | foreach {$_.tostring("yyyy, MMMM dd, dddd")}
}
$blackfriday