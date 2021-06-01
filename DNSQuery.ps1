$Website = $Args[0]
$IPv4 = '((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
$IPv6 = '([0-9A-Fa-f]{1,4}\:)(([0-9A-Fa-f]{1,4})?\:){1,6}[0-9A-Fa-f]{1,4}'
if (!(Test-Path $PSScriptRoot\RoundtripTime)) {New-Item -Path $PSScriptRoot -Name "RoundtripTime" -ItemType "Directory" | Out-Null}
if (!(Test-Path $PSScriptRoot\DNSResult)) {New-Item -Path $PSScriptRoot -Name "DNSResult" -ItemType "Directory" | Out-Null}
$Export = {if ($_ -notin $IP) {$IP+=$_; [PSCustomObject]@{Website = $Website ; Address = $_} | Export-Csv -Path $PSScriptRoot\DNSResult\${Website}_IP.csv -NoTypeInformation -Append}}
$IP=@()
$html = ConvertFrom-Html -uri "https://www.robtex.com/dns-lookup/$Website"
$html.SelectNodes('//table/tbody/tr/td/ul/li/a').InnerText | Where {$_ -match "$IPv4|$IPv6"} | %{Invoke-Command $Export}
$html.SelectNodes('//table/tbody/tr/td/a').InnerText | Where {$_ -match "$IPv4|$IPv6"} | %{Invoke-Command $Export}
$html.SelectNodes('//p/a').InnerText | Where {$_ -match "$IPv4|$IPv6"} | %{Invoke-Command $Export}
$DNSServers = Get-Content $PSScriptRoot\nameservers.txt
foreach ($DNS in $DNSServers) {
	$error.clear()
	Resolve-DnsName -Name "$Website" -Server $DNS -ErrorAction SilentlyContinue | Out-Null
	if (!$error) {
		(Resolve-DnsName -Name "$Website" -Server $DNS).IPAddress | %{Invoke-Command $Export}
	}
	else {
		$DNSServers = $DNSServers | where {$_ -ne $DNS}
	}
}
$DNSServers > $PSScriptRoot\nameservers.txt
$Ping = New-Object System.Net.Networkinformation.Ping
foreach ($addr in $IP) {
	$latency = 1..3 | %{$ping.Send($addr,300).RoundtripTime}
	$latency = [int]($latency | Measure-Object -Average).Average
	$latency = "{0:D3}" -f $latency
	[PSCustomObject]@{Website = $Website ; IPAddress = $addr ; Latency = $latency} | Export-Csv -Path "$PSScriptRoot\RoundtripTime\${Website}_Latency.csv" -NoTypeInformation -Append
}
$RTT = Import-Csv "$PSScriptRoot\RoundtripTime\${Website}_Latency.csv" | where {$_.Latency -ne '000'} | Sort-Object Latency
$RTT | Export-Csv -Path "$PSScriptRoot\RoundtripTime\${Website}_Latency.csv"