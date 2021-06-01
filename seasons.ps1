$timetable = Get-Content .\Desktop\txt\Equinox-Solstice.txt | Convertfrom-String -Templatefile .\Desktop\txt\template.txt
$count=$timetable.count
[array]$timetable1 = 0..99 | foreach-object {
$year=[string]$timetable[$_].year
$mequi=[datetime]($year+" "+$timetable[$_].marequi)
$jsols=[datetime]($year+" "+$timetable[$_].junsols)
$sequi=[datetime]($year+" "+$timetable[$_].sepequi)
$dsols=[datetime]($year+" "+$timetable[$_].decsols)
[pscustomobject]@{year=$year;mequi=$mequi;jsols=$jsols;sequi=$sequi;dsols=$dsols}
}
[array]$seasons=0..98 | foreach-object {
$year=$timetable1[$_].year
$spring=[double](New-Timespan -Start $timetable1[$_].mequi -End $timetable1[$_].jsols).totaldays
$summer=[double](New-Timespan -Start $timetable1[$_].jsols -End $timetable1[$_].sequi).totaldays
$autumn=[double](New-Timespan -Start $timetable1[$_].sequi -End $timetable1[$_].dsols).totaldays
$winter=[double](New-Timespan -Start $timetable1[$_].dsols -End $timetable1[$_+1].mequi).totaldays
[pscustomobject]@{year=$year;spring=$spring;summer=$summer;autumn=$autumn;winter=$winter}
}
$meanspring=($seasons.spring | Measure-Object -Average).average
$meansummer=($seasons.summer | Measure-Object -Average).average
$meanautumn=($seasons.autumn | Measure-Object -Average).average
$meanwinter=($seasons.winter | Measure-Object -Average).average
$meanyear=$meanspring+$meansummer+$meanautumn+$meanwinter
Write-Host "Mean Spring Length: $meanspring days, Mean Summer Length: $meansummer days, Mean Autumn Length: $meanautumn days, Mean Winter Length: $meanwinter days, Mean Solar Year Length: $meanyear days"