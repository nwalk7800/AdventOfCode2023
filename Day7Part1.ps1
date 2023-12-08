class CamelHand : System.IComparable {
    [string] $Cards
    [Int]$Bid
    [Int]$Rank

    hidden $CardRank = @{
        "2" = "2"
        "3" = "3"
        "4" = "4"
        "5" = "5"
        "6" = "6"
        "7" = "7"
        "8" = "8"
        "9" = "9"
        "T" = "A"
        "J" = "B"
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
        $ThisMatches = $Sorted | Select-String -Pattern '(.)\1{1,}' -AllMatches
        $MatchScore = 0
        [string]$Score = ""

        foreach ($Match in $ThisMatches.Matches) {
            $MatchScore += [Math]::Pow($Match.Length, 2)
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


$Hands = Get-Clipboard

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
