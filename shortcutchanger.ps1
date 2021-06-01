$linker = New-Object -ComObject WScript.Shell
$lnks = (Get-ChildItem -Path D:\NLinks -Force -Recurse -Filter "*.lnk").FullName
foreach ($lnk in $lnks) {
	$shortcut = $linker.CreateShortcut($lnk)
	if ($shortcut.TargetPath -match "C:\\") {
		$shortcut.TargetPath = $shortcut.TargetPath.replace('C:\','E:\')
		if ($shortcut.WorkingDirectory -match "C:\\") { $shortcut.WorkingDirectory = $shortcut.WorkingDirectory.replace('C:\','E:\') }
		if ($shortcut.IconLocation -match "C:\\") { $shortcut.IconLocation = $shortcut.IconLocation.replace('C:\','E:\') }
		$shortcut.Save()
	}
}