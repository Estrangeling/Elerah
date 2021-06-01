if (!(Test-Path $PSScriptRoot\nameservers.txt)) {
	$Result=Invoke-WebRequest -Uri "https://public-dns.info/nameservers.txt"
	if ($Result.StatusCode -eq 200) {$Result.Content >$PSScriptRoot\nameservers.txt}
}
Remove-Item "$PSScriptRoot\GetDNS_Log.csv" -ErrorAction SilentlyContinue
$SuccessRate=0
$loop=0
$Ping = New-Object System.Net.Networkinformation.Ping
while ($SuccessRate -lt 1) {
	$DNS=Get-Content $PSScriptRoot\nameservers.txt
	$DNS1=@()
	$loop+=1
	for ($i=0;$i -lt $DNS.count;$i++) {
		$Server=$DNS[$i]
		$latency=1..3 | %{$ping.Send($Server,256).RoundtripTime}
		$latency=($latency | Measure-Object -Average).Average
		if ($latency -eq 0 -or $latency -gt 256) {[PSCustomObject]@{Loop=$loop;Index=$i;Total=$DNS.Count;Server=$Server;Result="Failure"} | Export-Csv -Path "$PSScriptRoot\GetDNS_Log.csv" -NoTypeInformation -Append}
		else {$DNS1+=$Server;[PSCustomObject]@{Loop=$loop;Index=$i;Total=$DNS.Count;Server=$Server;Result="Success"} | Export-Csv -Path "$PSScriptRoot\GetDNS_Log.csv" -NoTypeInformation -Append}
	}
	$SuccessRate=$DNS1.count/$DNS.count
	$DNS1 >$PSScriptRoot\nameservers.txt
}
