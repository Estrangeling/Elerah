function List-TriNum($a){
	$b=0
	$c=0
	for($i=0;$i -lt $a;$i++) {
		$b=$c
		$c=$b+$i
		$c
	}
}