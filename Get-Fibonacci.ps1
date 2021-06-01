function Get-Fibonacci ($n) {
if ($n -le 1) {
return 1
}
return (Get-Fibonacci ($n - 1)) + (Get-Fibonacci ($n - 2))
}