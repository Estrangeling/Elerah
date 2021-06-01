function count-leap ($year) {
if ($year % 4 -eq 0) {$leap=$year/4}
else {while ($year % 4 -ne 0) {$year-=1}
$leap=$year/4}
if ($year % 100 -eq 0) {$century=$year/100}
else {while ($year % 100 -ne 0) {$year-=4}
$century=$year/100}
if ($year % 400 -eq 0) {$cycle=$year/400}
else {while ($year % 400 -ne 0) {$year-=100}
$cycle=$year/400}
$leap=$leap-$century+$cycle
$leap
}
$year=Read-Host "Input max year"
count-leap $year