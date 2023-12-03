$Engine = Get-Clipboard
$ToSum = @()
$PrevNumbers = @()
$PrevSymbols = @()

function GetAdjacent {
    param (
        $Numbers,
        $Symbols
    )
    
    foreach ($Number in $Numbers.Matches) {
        foreach ($Symbol in $Symbols.Matches) {
            if ($Symbol.Index -ge $Number.Index - 1 -and $Symbol.Index -le $Number.Index + $Number.Length) {
                [Int]$Number.Value
            }
        }
    }
}

foreach ($Line in $Engine) {
    $Numbers = $Line | Select-String -Pattern '\d+' -AllMatches
    $Symbols = $Line | Select-String -Pattern '[^\d\.]' -AllMatches

    $ToSum += GetAdjacent $Numbers $Symbols
    $ToSum += GetAdjacent $Numbers $PrevSymbols
    $ToSum += GetAdjacent $PrevNumbers $Symbols

    $PrevNumbers = $Numbers
    $PrevSymbols = $Symbols
}

($ToSum | Measure-Object -Sum).Sum