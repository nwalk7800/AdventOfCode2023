$Maps = ((Get-Clipboard) -join "`n") -split "`n`n"

function TiltNorth {
    param (
        $Map
    )

    do {
        $Change = $false
        for ($Row = 1; $Row -lt $Map.Count; $Row++) {
            for ($Col = 0; $Col -lt $Map[$Row].Count; $Col++) {
                if ($Map[$Row][$Col] -eq "O" -and $Map[$Row-1][$Col] -eq ".") {
                    $Map[$Row][$Col] = "."
                    $Map[$Row-1][$Col] = "O"
                    $Change = $true
                }
            }
        }
    } while ($Change)
}

function GetLoad {
    param (
        $Map
    )

    $Load = 0
    for ($Row = 0; $Row -lt $Map.Count; $Row++) {
        for ($Col = 0; $Col -lt $Map[$Row].Count; $Col++) {
            if ($Map[$Row][$Col] -eq "O") {
                $Load += $Map.Count - $Row
            }
        }
    }
    $Load
}

foreach ($MapText in $Maps) {
    $Map = @()
    foreach ($Row in $MapText -split "`n") {
        $Map += ,$Row.ToCharArray() 
    }

    TiltNorth $Map
    $Load = GetLoad $Map
}

$Load