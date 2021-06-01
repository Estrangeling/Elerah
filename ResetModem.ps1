[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
Start-Process -Filepath Telnet.exe -Argumentlist 192.168.1.1
Start-Sleep -Seconds 1
[System.Windows.Forms.SendKeys]::SendWait("root")
[System.Windows.Forms.SendKeys]::SendWait("{Enter}")
[System.Windows.Forms.SendKeys]::SendWait("adminHW")
[System.Windows.Forms.SendKeys]::SendWait("{Enter}")
[System.Windows.Forms.SendKeys]::SendWait("reset")
[System.Windows.Forms.SendKeys]::SendWait("{Enter}")
Get-Process -Name Telnet | Stop-Process
