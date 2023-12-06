$Data = Get-Clipboard
$Times = $Data[0].Split(" ", [StringSplitOptions]::RemoveEmptyEntries) | select -Skip 1 | %{[Int]$_}
$Dists = $Data[1].Split(" ", [StringSplitOptions]::RemoveEmptyEntries) | select -Skip 1 | %{[Int]$_}
$Wins = @()

for ($Race = 0; $Race -lt $Times.Count; $Race++) {
    $StartVal = [Math]::Ceiling($Dists[$Race] / $Times[$Race])

    while ($StartVal * ($Times[$Race] - $StartVal) -le $Dists[$Race]) {
        $StartVal++
    }

    $Win = 0
    for ($HoldTime = $StartVal; $HoldTime * ($Times[$Race] - $HoldTime) -gt $Dists[$Race]; $HoldTime++) {
        $Win++
    }

    $Wins += $Win
}

$Product = 1
foreach ($Win in $Wins) {
    $Product *= $Win
}

$Product