$execs = Get-ChildItem -Path D:\KDE\bin -File -Filter "*.exe" -Force -Recurse
foreach ($exec in $execs) {
	[System.Drawing.Icon]::ExtractAssociatedIcon($exec.FullName).ToBitmap().Save("$($exec.FullName).ico")
    if ((Get-FileHash "$($exec.FullName).ico").hash -ne "575EF7061A2EC30FCCDD46AC67E7DDB51F7B19215B4ADAC6BCF86B3D5A988616") {
		$exec.FullName
	}
	Remove-Item "$($exec.FullName).ico"
}
