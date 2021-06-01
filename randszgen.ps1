[string[]]$hex=0..9+"a".."f"
$randomhex=$(for ($i=0;$i -lt 100;$i++) {$hex[$((get-random -min 0 -max 160) % $hex.count)]}) -join ""
$randomhex=$randomhex -split "(\w{2})" | where{$_ -ne ""}
$($randomhex | %{[string][char][int]("0x"+"$_")}) -join ""

$randomstring=for ($i=0;$i -lt 100;$i++) {
	$choice=$(get-random -min 0 -max 99) % 2
	switch ($choice)
	{
		0 {[char]$(Get-Random -Min 65 -Max 90)}
		1 {[char]$(Get-Random -Min 97 -Max 122)}
	}
}
$randomstring=$randomstring -join ""
$randomstring
