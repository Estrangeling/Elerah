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

function Identify {
	PARAM (
		[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)] [System.String] $string, 
		[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=1)] [System.String] $regex
		)
		$string -eq ($string| Select-String -pattern $regex).matches.value
	}

function Date-d {
	PARAM(
 		[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)] $date1, 
		[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=1)] $date2
		)
		
	for ($i=0;$i -lt $Culture.count;$i++) {
		if (Identify $date1 $Culture[$i].Regex) {
			$date1=[DateTime]::ParseExact($date1,$Culture[$i].Format,$null)
			break
		}
	}
	for ($i=0;$i -lt $Culture.count;$i++) {
		if (Identify $date2 $Culture[$i].Regex) {
			$date2=[DateTime]::ParseExact($date2,$Culture[$i].Format,$null)
			break
		}
	}
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
Date-d $date1 $date2