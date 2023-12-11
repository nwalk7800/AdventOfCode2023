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

$Step = 1

while ($Map[$V][$H] -ne "S") {
    switch ($Map[$V][$H]) {
        "|" {
            if ($D -eq "Up") {$V--; $D = "Up"}
            else {$V++; $D = "Down"}
            Break
        }
        "-" {
            if ($D -eq "Right") {$H++; $D = "Right"}
            else {$H--; $D = "Left"}
            Break
        }
        "L" {
            if ($D -eq "Down") {$H++; $D = "Right"}
            else {$V--; $D = "Up"}
            Break
        }
        "J" {
            if ($D -eq "Right") {$V--; $D = "Up"}
            else {$H--; $D = "Left"}
            Break
        }
        "7" {
            if ($D -eq "Right") {$V++; $D = "Down"}
            else {$H--; $D = "Left"}
            Break
        }
        "F" {
            if ($D -eq "Left") {$V++; $D = "Down"}
            else {$H++; $D = "Right"}
        }
    }
    $Step++
}

$Step / 2