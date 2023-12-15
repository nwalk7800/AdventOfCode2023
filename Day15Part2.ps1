function ElfHash {
    param (
        $String
    )

    $Hash = 0
    for ($ndx = 0; $ndx -lt $String.Length; $ndx++) {
        $Hash += [byte][char]$String.SubString($ndx, 1)
        $Hash *= 17
        $Hash = $Hash % 256
    }

    $Hash
}

$Sequence = (Get-Clipboard) -split "," | ?{$_ -ne ""}

$Boxes = @{}
$Sum = 0
foreach ($Step in $Sequence) {
    if ($Step -match '(\w*)(=|-)(\d*)') {
        $Label = $Matches[1]
        $Operation = $Matches[2]
        $Value = $Matches[3]
    } else {
        "Bad"
    }

    $Box = ElfHash $Label
    if (-not $Boxes.ContainsKey($Box)) {
        $Boxes[$Box] = [ordered]@{}
    }

    if ($Operation -eq "=") {
        $Boxes[$Box][$Label] = $Value
    } else {
        $Boxes[$Box].Remove($Label)
    }
}

$Sum = 0
foreach ($Box in $Boxes.Keys) {
    $ndx = 0
    foreach ($Value in $Boxes[$Box].Keys) {
        $ndx++
        $Sum += ($Box + 1) * $ndx * $Boxes[$Box][$Value]
    }
}
$Sum