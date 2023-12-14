$Records = Get-Clipboard | ?{$_ -ne ""}

function Get-PossibleArrangements {
    param (
        $Record,
        $CRC,
        $Index = 0,
        $Found = 0
    )

    [Int]$Length = $CRC[0]
    $Arr = 0

    $Remainder = $Record.Substring($Index)

    for ($ndx = $Index; $ndx -le $Record.Length - $Length; $ndx++) {
        $NewFound = $Found
        $SLength = $Length + 2

        if ($ndx -eq 0) {
            $Regex = "(\.|\?|^)(\?|#){$Length}(\.|\?)"
            $StartIndex = 0
            $SLength--
        } else {
            $Regex = "(\.|\?)(\?|#){$Length}(\.|\?)"
            $StartIndex = $ndx - 1
        }

        if ($SLength -gt $Record.Length - $StartIndex) {
            $SLength = $Record.Length - $StartIndex
            $Regex = "(\.|\?)(\?|#){$Length}(\.|\?|$)"
        }

        $Substring = $Record.Substring($StartIndex, $SLength)
        if ($Substring -match $Regex) {
            $NewFound += $Length
            if ($CRC.Count -eq 1 -and $Record.Substring($StartIndex + $SLength) -notmatch "#") {
                $Arr++
            } elseif (($StartIndex + $Length + 1) -lt $Record.Length -and $CRC.Count -gt 1) {
                $Arr += Get-PossibleArrangements $Record -CRC $CRC[($Group+1)..($CRC.Length-$Group+1)] -Index ($StartIndex + $SLength) -Found $NewFound
            }
        } elseif ($ndx -eq 0 -and $Substring[0] -match "#" -or $ndx -gt 0 -and $Substring[0..1] -match "#") {
            break
        }
    }
    $Arr
}

$TotalArrange = 0
foreach ($Row in $Records) {
    $Record, $CRC = $Row -split " "
    $CRC = $CRC -split ","

    $TotalArrange += Get-PossibleArrangements $Record $CRC
}

$TotalArrange