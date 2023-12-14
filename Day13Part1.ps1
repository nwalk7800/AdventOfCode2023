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

    $Same = $true
    for ($ndx = 0; $ndx -lt $row1.Count; $ndx++) {
        if ($Row1[$ndx] -ne $Row2[$ndx]) {
            $Same = $false
            break
        }
    }
    $Same
}

function FindMirror {
    param (
        $Map
    )

    $Found = $false
    for ($Row = 0; $Row -lt $Map.Count - 1; $Row++) {
        $Prev = $Row
        $Next = $Row + 1
        
        while ($Prev -ge 0 -and $Next -lt $Map.Count) {
            if  (CompareRows $Map[$Prev] $Map[$Next]) {
                $Prev--
                $Next++
                $Found = $true
            } else {
                $Found = $false
                break
            }
        }

        if ($Found) {break}
    }

    if ($Found) {$Row + 1}
}

$Vertical = 0
$Horizontal = 0
foreach ($MapText in $Maps) {
    $Map = @()
    foreach ($Row in $MapText -split "`n") {
        $Map += ,$Row.ToCharArray() 
    }

    $Vertical += FindMirror (Transpose $Map)
    $Horizontal += FindMirror $Map
    
}

$Vertical + $Horizontal * 100