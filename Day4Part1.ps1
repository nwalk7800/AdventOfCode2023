$Sum = 0

foreach ($Card in Get-Clipboard) {
    $Game, $Winning, $Mine = $Card.Trim().split(':\|')
    $WinNumbers = $Winning.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)
    $MyNumbers = $Mine.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)

    $Hits = $MyNumbers | ?{$_ -in $WinNumbers}

    if ($hits.Count -gt 0) {
        $Sum += [Math]::Pow(2, $Hits.Count-1)
    }
}

$Sum