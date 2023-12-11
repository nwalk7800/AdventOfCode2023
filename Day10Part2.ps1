$Input = Get-Clipboard | ?{$_ -ne""}

$Map = @()

foreach ($Row in $Input) {
    $Match = $Row | Select-String "S"
    if ($Match.Count -gt 0) {
        $StartH = $Match.Matches[0].Index
        $StartV = $Map.Count
    }

    $Map += ,($Row -split "" | ?{$_ -ne ""})
}

if ($Map[$StartV-1][$StartH] -in "|","7","F") {
    $V = $StartV-1
    $H = $StartH
    $D = "Up"

} elseif ($Map[$StartV][$StartH+1] -in "-","J","7") {
    $V = $StartV
    $H = $StartH+1
    $D = "Right"

} elseif ($Map[$StartV+1][$StartH] -in "|","L","J") {
    $V = $StartV+1
    $H = $StartH
    $D = "Down"

} elseif ($Map[$StartV][$StartH+1] -in "-","L","F") {
    $V = $StartV
    $H = $StartH+1
    $D = "Left"
}

# I didn't bother finding the starting state programmatically, I just guessed
# There are only 4 possibilities
$InsideR = $true
$InsideU = $false
$Path = @{}

while ($Map[$V][$H] -ne "S") {
    $Path["$V,$H"] = $InsideR
    
    switch ($Map[$V][$H]) {
        "|" {
            if ($D -eq "Up") {$V--}
            else {$V++}
            Break
        }
        "-" {
            if ($D -eq "Right") {$H++}
            else {$H--}
            Break
        }
        "L" {
            if ($D -eq "Down") {
                $InsideU = $InsideR
                $D = "Right"
                $H++
            }
            else {
                $InsideR = $InsideU
                $Path["$V,$H"] = $InsideR
                $D = "Up"
                $V--
            }
            Break
        }
        "J" {
            if ($D -eq "Down") {
                $InsideU = -not $InsideR
                $D = "Left"
                $H--
            }
            else {
                $InsideR = -not $InsideU
                $Path["$V,$H"] = $InsideR
                $D = "Up"
                $V--
            }
            Break
        }
        "7" {
            if ($D -eq "Up") {
                $InsideU = $InsideR
                $D = "Left"
                $H--
            }
            else {
                $InsideR = $InsideU
                $Path["$V,$H"] = $InsideR
                $D = "Down"
                $V++
            }
            Break
        }
        "F" {
            if ($D -eq "Up") {
                $InsideU = -not $InsideR
                $D = "Right"
                $H++
            }
            else {
                $InsideR = -not $InsideU
                $Path["$V,$H"] = $InsideR
                $V++; $D = "Down"
            }
        }
    }
}

$Path["$V,$H"] = $InsideR
$Count = 0

foreach ($Step in $Path.Keys) {
    if ($Path[$Step]) {
        [Int]$V,[Int]$H = $Step -split ","
        $H++

        while (-not $Path.ContainsKey("$V,$H")) {
            if ($H -gt $Map[0].Count) {
                Write-Host
            }
            $Map[$V][$H] = "I"
            $Count++
            $H++
        }
    }
}

foreach ($Row in $Map) {$Row -join ""}

$Count