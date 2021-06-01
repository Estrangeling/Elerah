$Desktop = [Environment]::GetFolderPath('Desktop')
$AppData = [Environment]::GetFolderPath('ApplicationData')
$defreg = '[a-z]+://([a-z0-9\-]+[\.]){2}[a-z0-9\-]+([\.][a-z]{2,3})?'
$definput = "$AppData\Lantern\logs\Lantern.log"
$defoutput = "$Desktop\webaddr.txt"
$input_path = Read-Host "please input file path"
if(-not($input_path)){
    $input_path = $definput
}
elseif (("$input_path".Split("\"))[0] -eq "AppData") {$input_path = ("$input_path" -replace "AppData", "$AppData")}
elseif (("$input_path".Split("\"))[0] -eq "Desktop") {$input_path = ("$input_path" -replace "Desktop", "$Desktop")}
Write-Host "$input_path"
$output_path = Read-Host "please specify output path"
if(-not($output_path)){
    $output_path= $defoutput
}
elseif (("$output_path".Split("\"))[0] -eq "AppData") {$output_path = ("$output_path" -replace "AppData", "$AppData")}
elseif (("$output_path".Split("\"))[0] -eq "Desktop") {$output_path = ("$output_path" -replace "Desktop", "$Desktop")}
Write-Host "$output_path"
$regex = Read-Host "please enter regular expression"
if(-not($regex)){
    $regex = $defreg
}
Write-Host "$regex"
select-string -Path "$input_path" -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Value } | Out-File -FilePath "$output_path"
If ($regex -eq $defreg) {(Get-Content "$output_path") -replace '[a-z]+://' | Sort | Get-Unique| Out-File -FilePath "$output_path"}
 