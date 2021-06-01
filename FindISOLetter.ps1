$Letter=(Get-DiskImage -ImagePath D:\ISO\Win10_20H2_v2_English_x64.iso | Get-Volume).DriveLetter
IF (!$Letter) {Mount-DiskImage -ImagePath D:\ISO\Win10_20H2_v2_English_x64.iso -StorageType ISO}
$Letter=(Get-DiskImage -ImagePath D:\ISO\Win10_20H2_v2_English_x64.iso | Get-Volume).DriveLetter
