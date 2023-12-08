function Gcd {
    param (
        $Num1,
        $Num2
    )

    while ($Num2) {
        $temp = $Num2
        $Num2 = $Num1 % $Num2
        $Num1 = $temp
    }

    $Num1
}

function Gcd-Range {
    param (
        [Int[]]$Numbers
    ) 

    $Gcd = $Numbers[0]
    for ($ndx = 1; $ndx -lt $Numbers.Count; $ndx++) {
        $Gcd = Gcd $Gcd $Numbers[$ndx]
    }
    $Gcd
}

function Get-Gcm {
    param (
        $Numbers
    )

    $Gcd = Gcd-Range $Numbers
    
    $Gcm = 1
    foreach ($Number in $Numbers) {
        $Gcm *= $Number / $Gcd
    }

    $Gcm * $Gcd
}

$Map = Get-Clipboard | ?{$_ -ne ""}

$Instructions = $Map[0] -split "" | ?{$_ -ne ""}

$Nodes = @{}
for ($ndx = 1; $ndx -lt $Map.Count; $ndx++) {
    $Node, $Directions = $Map[$ndx] -split "="
    $Left, $Right = $Directions -split ","
    
    $Nodes[$Node.Trim()] = "" | select @{n="L";e={$Left.Trim() -replace "\("}},@{n="R";e={$Right.Trim() -replace "\)"}}
}

$Paths = @{}
foreach ($Node in $Nodes.Keys) {
    if ($Node.Substring(2,1) -eq "A") {
        $Paths[$Node] = "" | select @{n="Node";e={$Node}},Done,Step
    }
}

$Node = "AAA"
$Step = 0
$Instruction = 0
$AllZ = $false

while (-not $AllZ) {
    $AllZ = $true
    foreach ($Path in $($Paths.Keys)) {
        if ($Paths[$Path].Done -ne $true) {
            $Paths[$Path].Node = $Nodes[$Paths[$Path].Node].($Instructions[$Instruction])
        
            if ($Paths[$Path].Node.Substring(2,1) -eq "Z") {
                $Paths[$Path].Done = $true
                $Paths[$Path].Step = $Step + 1
            } else {
                $AllZ = $false
            }
        }
    }
    
    $Instruction++
    if ($Instruction -ge $Instructions.Count) {
        $Instruction = 0
    }
    $Step++
}

$Steps = @()
foreach ($Path in $Paths.Keys) {
    $Steps += $Paths[$Path].Step
}

Get-Gcm $Steps