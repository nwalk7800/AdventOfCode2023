$Maps = ((Get-Clipboard) -join "`n") -split "`n`n"

function Transpose {
    param (
        $Map
    )
    
    $NewMap = @()
    for ($Col = 0; $Col -lt $Map[0].Count; $Col++) {
        $Column = @()
        for ($Row = 0; $Row -lt $Map.Count; $Row++) {
            $Column += $Map[$Row][$Col]
        }
        $NewMap += ,$Column
    }
    $NewMap
}

function CompareRows {
    param (
        $Row1,
        $Row2
    )

    $Diffs = 0
    for ($ndx = 0; $ndx -lt $row1.Count; $ndx++) {
        if ($Row1[$ndx] -ne $Row2[$ndx]) {
            $Diffs++
        }
    }
    $Diffs
}

function FindMirror {
    param (
        $Map,
        $Smudges = 1
    )

    $Found = $false
    for ($Row = 0; $Row -lt $Map.Count - 1; $Row++) {
        $Prev = $Row
        $Next = $Row + 1
        $TotalDiffs = 0
        
        while ($Prev -ge 0 -and $Next -lt $Map.Count) {
            $Diffs = CompareRows $Map[$Prev] $Map[$Next]
            $TotalDiffs += $Diffs

            if  ($TotalDiffs -le $Smudges) {
                $Prev--
                $Next++
                $Found = $true
            } else {
                $Found = $false
                break
            }
        }

        if ($Found -and $TotalDiffs -eq $Smudges) {
            break
        }
    }

    if ($Found -and $TotalDiffs -eq $Smudges) {$Row + 1}
}

$Vertical = 0
$Horizontal = 0
foreach ($MapText in $Maps) {
    $Map = @()
    foreach ($Row in $MapText -split "`n") {
        $Map += ,$Row.ToCharArray() 
    }
    
    $TempH = FindMirror $Map
    $TempV = FindMirror (Transpose $Map)

    if ($TempV -and $TempH) {
        Write-Host
    }
    
    $Horizontal += $TempH
    $Vertical += $TempV
}

$Vertical + $Horizontal * 100