IF ((Get-FileHash -Path D:\ISO\Win10_21H1_English_x64.iso).hash -eq "6911E839448FA999B07C321FC70E7408FE122214F5C4E80A9CCC64D22D0D85EA") {
	$Letter=(Get-DiskImage -ImagePath D:\ISO\Win10_21h1_English_x64.iso | Get-Volume).DriveLetter
	IF (!$Letter) {Mount-DiskImage -ImagePath D:\ISO\Win10_21h1_English_x64.iso -StorageType ISO}
	$Letter=(Get-DiskImage -ImagePath D:\ISO\Win10_21h1_English_x64.iso | Get-Volume).DriveLetter
	dism /online /cleanup-image /startcomponentcleanup /resetbase
	dism /online /cleanup-image /spsuperseded
	dism /online /cleanup-image /restorehealth /source:${Letter}:\sources\install.wim:6 /limitaccess
	sfc /scannow
}