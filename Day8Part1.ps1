$Map = Get-Clipboard | ?{$_ -ne ""}

$Instructions = $Map[0] -split "" | ?{$_ -ne ""}

$Nodes = @{}
for ($ndx = 1; $ndx -lt $Map.Count; $ndx++) {
    $Node, $Directions = $Map[$ndx] -split "="
    $Left, $Right = $Directions -split ","
    
    $Nodes[$Node.Trim()] = "" | select @{n="L";e={$Left.Trim() -replace "\("}},@{n="R";e={$Right.Trim() -replace "\)"}}
}

$Node = "AAA"
$Step = 0
$Instruction = 0
while ($Node -ne "ZZZ") {
    $Node = $Nodes[$Node].($Instructions[$Instruction])
    $Instruction++
    if ($Instruction -ge $Instructions.Count) {
        $Instruction = 0
    }
    $Step++
}

$Step