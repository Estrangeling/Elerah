function leaps ($year) {
$y=$year
$leaps=[math]::floor($y/4)-[math]::floor($y/100)+[math]::floor($y/400)
$leaps
}
$year=Read-Host "Input max year"
leaps $year