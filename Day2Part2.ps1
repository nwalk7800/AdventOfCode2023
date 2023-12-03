$Sample = Get-Clipboard
$Max = @{
    "red" = 12
    "green" = 13
    "blue" = 14
}

$Sum = 0

foreach ($Game in $Sample) {

    $TotalColors = @{
        "red" = 0
        "green" = 0
        "blue" = 0
    }

    $Title, $Grabs = $Game -split ":"
    $Id = [Int]($Title -split " ")[1]
    
    foreach ($Grab in ($Grabs -split ";")) {
        foreach ($Group in ($Grab -split ",")) {
            [Int]$Count, $Color = $Group.Trim() -split " "
            $TotalColors[$Color] = [Math]::Max($TotalColors[$Color], $Count)
        }
    }

    $Sum += $TotalColors["red"] * $TotalColors["green"] * $TotalColors["blue"]
}

$Sum