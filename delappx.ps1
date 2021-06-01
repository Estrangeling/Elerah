$blacklist="549981C3F5F10|Phone|Xbox|Get|Camera|FeedBack|Solitaire|People|OneNote|Search|Parent|Cloud|Wallet|Bio|Call|CBS|AppRep"
Get-AppxPackage | where {$_.Name -match $blacklist} | Remove-AppxPackage -AllUsers
Get-AppxProvisionedPackage -Online | where {$_.DisplayName -match $blacklist} | Remove-AppxProvisionedPackage -Online