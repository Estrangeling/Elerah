function GainAccess($directory) {
	if ($directory -match "\s") {$directory='"'+$directory+'"'}
	takeown /R /A /F $directory /D N
	cmd /c "icacls $directory /inheritance:e /grant:r Administrators:(OI)(CI)F /C"
	icacls $directory /setowner "NT SERVICE\TrustedInstaller" /T /C
}
$directory=$args[0]
GainAccess $directory
