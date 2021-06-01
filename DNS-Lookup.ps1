$Website = Read-Host "please input website"
$IPv4Regex = '((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
$IPv6Regex = '([0-9A-Fa-f]{1,4}\:)(([0-9A-Fa-f]{1,4})?\:){1,6}[0-9A-Fa-f]{1,4}'
$DNSServers = Get-Content "$Desktop\nameservers.txt"
$TotalDNS = ( $DNSServers | Measure-Object | Select-Object Count).Count
$Desktop = [Environment]::GetFolderPath('Desktop')
$hostsfile = "$Desktop\hostsfile.txt"
function grep ($string) {
	$input | out-string -stream | select-string -pattern $string
	}
function add-unique($file) { 
	$list = Get-Content $file
	$input | Where-Object {$_ -notin $list} | Out-File -Append  -FilePath $file
	}
$a=0
$b=0
$c=0
$d=0
$errnum=0
$DNSServers | Set-Content "$Desktop\DNS ${b}.txt"
if(![System.IO.File]::Exists("$Desktop\IPLIST\${Website} IP.txt")) {New-Item -Path "$Desktop\IPLIST" -Name "${Website} IP.txt" -ItemType "file" | Out-Null}
$html = ConvertFrom-Html -uri "https://www.robtex.com/dns-lookup/$Website"
$html.SelectNodes('//table/tbody/tr/td/ul/li/a') | grep $IPv4Regex,$IPv6Regex -AllMatches | % { $_.Matches } | % { $_.Value } | add-unique "$Desktop\IPLIST\${Website} IP.txt"
$html.SelectNodes('//table/tbody/tr/td/a') | grep $IPv4Regex,$IPv6Regex -AllMatches | % { $_.Matches } | % { $_.Value } | add-unique "$Desktop\IPLIST\${Website} IP.txt"
$html.SelectNodes('//p/a') | grep $IPv4Regex,$IPv6Regex -AllMatches | % { $_.Matches } | % { $_.Value } | add-unique "$Desktop\IPLIST\${Website} IP.txt"
$xml = Invoke-RestMethod -Uri "https://www.whoisxmlapi.com/whoisserver/DNSService?apiKey=at_XtSRfNeGga9JKpxlkuJiNB7hhiFLS&domainName=${Website}&type=1"
$xml.SelectNodes("//address") |  grep $IPv4Regex,$IPv6Regex -AllMatches | % { $_.Matches } | % { $_.Value } | add-unique "$Desktop\IPLIST\${Website} IP.txt"
$html1 = ConvertFrom-Html -uri "https://dnslookup.org/${Website}/A/#delegation"
$html1.SelectNodes('//tr/td') | grep $IPv4Regex,$IPv6Regex -AllMatches | % { $_.Matches } | % { $_.Value } | add-unique "$Desktop\IPLIST\${Website} IP.txt"
for ( $i=0;$i -lt $TotalDNS;$i++) {
	$DNS = $DNSServers | Select-Object -index $i
	$error.clear()
	Resolve-DnsName -Name "$Website" -Server $DNS -ErrorAction SilentlyContinue | Out-Null
	if (!$error) 
	{
	$IPv4 = Resolve-DnsName -Name "$Website" -Server $DNS | Select-Object  IP4Address
	$IPv6 = Resolve-DnsName -Name "$Website" -Server $DNS | Select-Object  IP6Address
	$IPv4|grep $IPv4Regex -AllMatches | % { $_.Matches } | % { $_.Value } | add-unique "$Desktop\IPLIST\${Website} IP.txt"
	$IPv6|grep $IPv6Regex -AllMatches | % { $_.Matches } | % { $_.Value } | add-unique "$Desktop\IPLIST\${Website} IP.txt"
	} else { 
	$b=$a
	$a+=1
	Get-Content "$Desktop\DNS ${b}.txt" | Where-Object {$_ -notmatch $DNS} | Out-File "$Desktop\DNS ${a}.txt" 
	remove-item "C:\Users\Comma\Desktop\DNS ${b}.txt"
	$errnum+=1
	}
}
$IPs = Get-Content "$Desktop\IPLIST\${Website} IP.txt"
$TotalIPs = ($IPs | Measure-Object | Select-Object Count).Count
if(![System.IO.File]::Exists("$Desktop\IPLIST\${Website} Ping Result.txt")) {New-Item -Path "$Desktop\IPLIST" -Name "${Website} Ping Result.txt" -ItemType "file" | Out-Null}
$PingResult = "$Desktop\IPLIST\${Website} Ping Result.txt"
for ($n=0;$n -lt $TotalIPs;$n++) {
	$IP =  $IPs| Select-Object -index $n
	$ping = (Test-Connection -targetname $IP -ping -count 4 -timeoutseconds 1 | Select-Object -ExpandProperty Latency | Measure-Object -Average).average -as [int]
	if ( $ping -ne 0) { 
	$ping = "{0:D3}" -f $ping 
	"$ping $IP" | out-file -path $PingResult -append
	}
}
$SortedIP = Get-Content $PingResult | Sort-Object | grep $IPv4Regex,$IPv6Regex -AllMatches | % { $_.Matches } | % { $_.Value }
$UsableIP = $SortedIP | Select-Object -index 0
if ($UsableIP -ne $null) {
write-host "$UsableIP $Website"
"$UsableIP $Website" | add-unique "$hostsfile"
}
if ([System.IO.File]::Exists("$Desktop\DNS ${errnum}.txt") -eq $true) {Get-Content -Path "$Desktop\DNS ${errnum}.txt" | Out-File -FilePath "$Desktop\nameservers.txt"
Remove-Item -Path "$Desktop\DNS ${errnum}.txt" }