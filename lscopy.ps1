function lscopy {
	param (
	[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)] [string] $file,
	[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=1)] [string] $root,
	[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=2)] [string] $dest
	)
	$list = get-content -path $file
	if (-not $root.endswith('\')) {$root = $root + '\'}
	if (-not $dest.endswith('\')) {$dest = $dest + '\'}
	foreach ($path in $list) {
		$tree = $path.replace($root,'').split('\')
		if (!(test-path $($dest + ($tree[0..$($tree.count - 2)] -join '\')))) {
			for ($i=0; $i -lt $tree.count - 1; $i++) {
				$folder = $dest + ($tree[0..$i] -join '\')
				if (!(Test-Path $folder)) { new-item -path $folder -itemtype directory | out-null}
			}
		}
		if (!(Test-Path $path -PathType Container)) { 'f' | xcopy $path $path.replace($root,$dest) /f /h /k /y | out-null }
		else { robocopy $path $path.replace($root,$dest) /s /mt:128 /r:3 /w:3 /copy:DAT /is /it | out-null }
	}
}
$file = $Args[0]
$root = $Args[1]
$dest = $Args[2]
lscopy $file $root $dest