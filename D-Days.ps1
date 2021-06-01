function D-Days {
	PARAM(
 		[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)] $date1, 
		[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=1)] $date2
		)
		
	$date1=[DateTime]$date1
	$date2=[DateTime]$date2
	$ddate=New-TimeSpan -Start $date1 -End $date2
	$date1=$date1.ToString("MMMM dd, yyyy")
	$date2=$date2.ToString("MMMM dd, yyyy")
	$length=([string]$ddate.days).length
	$ddate=$ddate.ToString("d"*$length)
	Write-Output "Start date is: $date1, End date is: $date2, Date difference is: $ddate days"
	}
$date1=Read-Host "Input Start Date"
if (-not $date1) {
	$date1="1999-04-10"
}
Write-Host $date1
$date2=Read-Host "Input End Date"
if (-not $date2) {
	$date2=(Get-Date -DisplayHint Date -Format "yyyy-MM-dd" | Out-String).TrimEnd()
}
Write-Host $date2
D-Days $date1 $date2