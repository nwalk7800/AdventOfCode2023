
function SumCards {
    param (
        $Cards
    )
    
    $CardsTotal = 0
    
    foreach ($Card in $Cards) {
        $CardTotal = 0
        
        if ($SavedCards.ContainsKey($Card.GameNum)) {
            $CardTotal = $SavedCards[$Card.GameNum]
        } else {
            $Hits = @($Card.MyNumbers | ?{$_ -in $Card.WinNumbers})

            if ($Hits.Length -gt 0) {
                $CardTotal += $Hits.Length
                $CardTotal += SumCards $AllCards[$Card.GameNum..($Card.GameNum+$Hits.Length-1)]
            }
            $SavedCards[$Card.GameNum] = $CardTotal
        }
        $CardsTotal += $CardTotal
    }
    $CardsTotal
}

$AllCards = Get-Clipboard | %{
    $Game, $Winning, $Mine = $_.Trim().split(':\|')
    
    $Retval = "" | select GameNum, WinNumbers, MyNumbers
    [Int]$Retval.GameNum = $Game.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)[1]
    $Retval.WinNumbers = $Winning.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)
    $Retval.MyNumbers = $Mine.Split(" ", [StringSplitOptions]::RemoveEmptyEntries)

    $Retval
}

$SavedCards = @{}

$Sum = $AllCards.Length

$Sum += SumCards $AllCards

$Sum