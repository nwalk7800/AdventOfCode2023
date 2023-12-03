$Engine = Get-Clipboard
$ToSum = @()
$GearDic = @{}
$PrevNumbers = @()
$PrevSymbols = @()

function GetAdjacent {
    param (
        $Numbers,
        $Symbols
    )
    
    foreach ($Number in $Numbers.Matches) {
        foreach ($Gear in $Symbols.Matches) {
            if ($Gear.Index -ge $Number.Index - 1 -and $Gear.Index -le $Number.Index + $Number.Length) {
                if (-not $GearDic.ContainsKey($Gear)) {
                    $GearDic[$Gear] = @()
                }
                $GearDic[$Gear] += [Int]$Number.Value
            }
        }
    }
}

foreach ($Line in $Engine) {
    $Numbers = $Line | Select-String -Pattern '\d+' -AllMatches
    $Symbols = $Line | Select-String -Pattern '\*' -AllMatches

    GetAdjacent $Numbers $Symbols
    GetAdjacent $Numbers $PrevSymbols
    GetAdjacent $PrevNumbers $Symbols

    $PrevNumbers = $Numbers
    $PrevSymbols = $Symbols
}

foreach ($Key in $GearDic.Keys) {
    if ($GearDic[$Key].Count -eq 2) {
        $ToSum += $GearDic[$Key][0] * $GearDic[$Key][1]
    }
}

($ToSum | Measure-Object -Sum).Sum