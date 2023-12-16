function Clone {
    param (
        $Map
    )

    $Clone = @()
    for ($Row = 0; $Row -lt $Map.Count; $Row++) {
        $Clone += ,$Map[$Row].Clone()
    }
    $Clone
}

function Energize {
    param (
        $x,
        $y,
        $XDir,
        $YDir
    )

    $temp = 0

    while ($x -ge 0 -and $x -lt $Map[0].Count -and $y -ge 0 -and $y -lt $Map.Count) {
        $VisualMap[$y][$x] = "#"
        if (-not ($Energized["$x,$y"] -eq "$XDir,$YDir")) {
            $Energized["$x,$y"] = "$XDir,$YDir"
        } else {
            break
        }

        switch ($Map[$y][$x]) {
        
            "." {
                $x += $XDir
                $y += $YDir
                break
            }
        
            "-" {
                if ($XDir -ne 0) {
                    $x += $XDir
                } else {
                    Energize ($x-1) $y -1 0
                    $XDir = 1
                    $YDir = 0
                    $x++
                }
                break
            }

            "|" {
                if ($XDir -ne 0) {
                    Energize $x ($y-1) 0 -1
                    $XDir = 0
                    $YDir = 1
                    $y++
                } else {
                    $y += $YDir
                }
                break
            }

            "/" {
                if ($XDir -ne 0) {
                    $YDir -= $XDir
                    $XDir = 0
                    $y += $YDir
                } else {
                    $XDir -= $YDir
                    $YDir = 0
                    $x += $XDir
                }
                break
            }

            "\" {
                if ($XDir -ne 0) {
                    $YDir = $XDir
                    $XDir = 0
                    $y += $YDir
                } else {
                    $XDir = $YDir
                    $YDir = 0
                    $x += $XDir
                }
                break
            }
        }
    }
}

$MapText = Get-Clipboard

$Map = @()
foreach ($Row in $MapText) {
    $Map += ,$Row.ToCharArray()
}

$VisualMap = Clone $Map

$Energized = @{}

Energize 0 0 1 0

$Energized.Count