$Blacklist = @(
"549981C3F5F10"
"AAD"
"Advertising"
"Bio"
"Call"
"Camera"
"CBS"
"Cloud"
"Get"
"NcsiUwpApp"
"One"
"Parent"
"People"
"Phone"
"Search"
"SecHealthUI"
"Skype"
"Undock"
"Wallet"
"Xbox"
"Zune"
)
Get-AppxPackage | where {$_.Name -match ($Blacklist -join '|')} | Remove-AppxPackage
