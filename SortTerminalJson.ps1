$json=gc "C:\Users\Estranger\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json" | Out-String | ConvertFrom-Json
$json.profiles.list = $json.profiles.list | sort name
$json | ConvertTo-Json -Depth 3 > "C:\Users\Estranger\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"