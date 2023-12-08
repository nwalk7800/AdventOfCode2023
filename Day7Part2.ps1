class CamelHand : System.IComparable {
    [string] $Cards
    [Int]$Bid
    [Int]$Rank

    hidden $CardRank = @{
        "J" = "1"
        "2" = "2"
        "3" = "3"
        "4" = "4"
        "5" = "5"
        "6" = "6"
        "7" = "7"
        "8" = "8"
        "9" = "9"
        "T" = "A"
        "Q" = "C"
        "K" = "D"
        "A" = "E"
    }

    CamelHand ([string]$Cards, [Int]$Bid) {
        $this.Cards = $Cards
        $this.Bid = $Bid
        $this.RankHand()
    }

    RankHand() {
        $Sorted = ($this.Cards -split "" | sort) -join ""

        $JokerCount = ($Sorted | Select-String -Pattern 'J' -AllMatches).Matches.Count

        $ThisMatches = ($Sorted -replace "J","") | Select-String -Pattern '(.)\1{1,}' -AllMatches
        $MatchScore = 0
        [string]$Score = ""
        $LongestMatch = 0

        if ($ThisMatches.Count -gt 0) {
            $MatchesLengths = @()
            $MaxMatch = 0
            foreach ($Match in $ThisMatches.Matches) {
                $MatchesLengths += $Match.Length

                if ($Match.Length -gt $MaxMatch) {
                    $MaxMatch = $Match.Length
                    $LongestMatch = $MatchesLengths.Count - 1
                }
            }
        } elseif ($JokerCount -eq 5) {
            $MatchesLengths += 0
        } else {
            $MatchesLengths += 1
        }

        for ($Match = 0; $Match -lt $MatchesLengths.Count; $Match++) {
            if ($Match -eq $LongestMatch) {
                $MatchScore += [Math]::Pow($MatchesLengths[$Match] + $JokerCount, 2)
            } else {
                $MatchScore += [Math]::Pow($MatchesLengths[$Match], 2)
            }
        }

        $Score = $MatchScore

        foreach ($Card in $this.Cards -split "" | ?{$_ -ne ""}) {
            $Score += $this.CardRank[$Card]
        }

        $this.Rank = [Convert]::ToInt64($Score, 16)
    }

    [int] CompareTo($OtherHand) {
        if ($this.Rank -gt $OtherHand.Rank) {return 1}
        if ($this.Rank -eq $OtherHand.Rank) {return 0}
        if ($this.Rank -lt $OtherHand.Rank) {return -1}
        return $null
    }
}


$Hands = Get-Clipboard | ?{$_ -ne ""}

$AllHands = @()

foreach ($Hand in $Hands) {
    $Cards, $Bid = $Hand -split " "
    $AllHands += New-Object CamelHand $Cards, $Bid
}

$SortedHands = $AllHands | sort

$TotalWinnings = 0
for ($ndx = 1; $ndx -le $SortedHands.Count; $ndx++) {
    $TotalWinnings += $SortedHands[$ndx-1].Bid * $ndx
}

$TotalWinnings
