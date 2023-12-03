$sum = 0
Get-Clipboard | %{
    $m = $_ | Select-String -Pattern '\d' -AllMatches
    $s = "{0}{1}" -f $m.matches[0].value, $m.matches[-1].value
    $sum += [int]$s
}
$sum