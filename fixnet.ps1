[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 
Start-Process -Filepath Telnet.exe -Argumentlist 192.168.1.1
Start-Sleep -Seconds 3
[System.Windows.Forms.SendKeys]::SendWait("root")
[System.Windows.Forms.SendKeys]::SendWait("{Enter}")
Start-Sleep -Seconds 2
[System.Windows.Forms.SendKeys]::SendWait("adminHW")
[System.Windows.Forms.SendKeys]::SendWait("{Enter}")
Start-Sleep -Seconds 2
[System.Windows.Forms.SendKeys]::SendWait("reset")
[System.Windows.Forms.SendKeys]::SendWait("{Enter}")
Start-Sleep -Seconds 2
Get-Process -Name Telnet | Stop-Process

devcon disable *dev_8168*
devcon enable *dev_8168*
start-sleep -seconds 3
netsh winsock reset
netsh winhttp reset proxy
netsh http flush log buffer
net start dot3svc
netsh lan reconnect
net stop dot3svc
start-sleep -seconds 3
netsh int ip reset
netsh int ipv4 reset
netsh int ipv6 reset
netsh int httpstunnel reset
netsh int portproxy reset
netsh int tcp reset
start-sleep -seconds 3
ipconfig /release
ipconfig /all
ipconfig /flushdns
ipconfig /registerdns
ipconfig /renew

RunDll32.exe InetCpl.cpl,ResetIEtoDefaults
Start-Sleep -Seconds 1
[System.Windows.Forms.SendKeys]::SendWait("{Tab}")
[System.Windows.Forms.SendKeys]::SendWait(" ")
[System.Windows.Forms.SendKeys]::SendWait("R")
Start-Sleep -Seconds 3
[System.Windows.Forms.SendKeys]::SendWait("C")

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyEnable" -Type DWord -Value 1
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -Name "ProxyOverride" -Type String -Value "login.live.com;account.live.com;clientconfig.passport.net;wustat.windows.com;*.windowsupdate.com;*.wns.windows.com;*.hotmail.com;*.outlook.com;*.microsoft.com;*.msftncsi.com;<local>"
