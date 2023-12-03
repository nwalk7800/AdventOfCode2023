$Sample = Get-Clipboard
$Max = @{
    "red" = 12
    "green" = 13
    "blue" = 14
}

$IdTotal = 0

foreach ($Game in $Sample) {

    $Possible = $true
    $Title, $Grabs = $Game -split ":"
    $Id = [Int]($Title -split " ")[1]
    
    foreach ($Grab in ($Grabs -split ";")) {
        foreach ($Group in ($Grab -split ",")) {
            [Int]$Count, $Color = $Group.Trim() -split " "
            if ($Count -gt $Max[$Color]) {
                $Possible = $false
                break
            }
        }
    }

    if ($Possible) {
        $IdTotal += $Id
    }
}

$IdTotal