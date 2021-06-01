$Desktop = [Environment]::GetFolderPath('Desktop')
$Websites = Get-Content $Desktop\WebAddress.txt
foreach ($line in $Websites) {
	&$PSScriptRoot\DNSQuery.ps1 $line
	$IP = (Import-Csv $PSScriptRoot\RoundTripTime\${line}_Latency.csv)[0].IPAddress
	$Hosts = Get-Content $Env:Windir\System32\drivers\etc\hosts
	$Hosts = $Hosts | where {$_ -notmatch $line}
	$Hosts += "$IP $line"
	$Hosts > $Env:Windir\System32\drivers\etc\hosts
}
