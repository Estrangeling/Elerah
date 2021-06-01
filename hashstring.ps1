function hashstring {
	Param (
		[Parameter(Mandatory=$true)] [string] $String
	)

	$hasher = [System.Security.Cryptography.HashAlgorithm]::Create('sha256')
	$hash = $hasher.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($String))

	$hashString = [System.BitConverter]::ToString($hash)
	$hashString.Replace('-', '')
}
$string = $Args[0]
hashstring $string