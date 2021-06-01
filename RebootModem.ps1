Start-Process -Filepath cscript.exe -Argumentlist $PSScriptRoot\RebootModem.vbs
Start-Sleep -Seconds 6
Get-Process -Name Telnet | Stop-Process
