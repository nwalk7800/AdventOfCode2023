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

$Sum = 0
foreach ($Step in $Sequence) {
    $Sum += ElfHash $Step
}

$Sum