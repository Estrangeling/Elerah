function listcopy {
	param (
	[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=0)] [array] $list,
	[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=1)] [string] $root,
	[Parameter(ValueFromPipeline=$true, Mandatory=$true, Position=2)] [string] $dest
	)
	if (-not $root.endswith('\')) {$root = $root + '\'}
	if (-not $dest.endswith('\')) {$dest = $dest + '\'}
	foreach ($path in $list) {
		if (-not (Test-Path $path -PathType Container)) {
			$tree = $path.replace($root,'').split('\')
			for ($i=0; $i -lt $tree.count - 1; $i++) {
				$folder = $dest + ($tree[0..$i] -join '\')
				if (!(Test-Path $folder)) { new-item -path $folder -itemtype directory | out-null}
			}
			Copy-Item -Path $path -Destination $path.replace($root,$dest)
		}
		else { listcopy $((get-childitem -path $path -force -recurse).fullname) $root $dest}
	}
}
$list = $Args[0]
$root = $Args[1]
$dest = $Args[2]
listcopy $list $root $dest