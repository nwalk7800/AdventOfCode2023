$Histories = Get-Clipboard | ?{$_ -ne ""}
$Sum = 0

foreach ($History in $Histories) {
    $Rows = @()
    
    $Rows += ,($History -split " ")
    [array]::Reverse($Rows[0])

    $ndx = 0
    do {
        $ndx++
        $NextRow = @()
        for ($Value = 0; $Value -lt $Rows[$ndx-1].Count - 1; $Value++) {
            $NextRow += $Rows[$ndx-1][$Value+1] - $Rows[$ndx-1][$Value]
        }
        $Rows += ,$NextRow
    } while (($Rows[$ndx] | select -Unique) -ne 0)


    $Ext = 0
    for ($Row = $Rows.Count - 2; $Row -ge 0; $Row--) {
        $Ext += $Rows[$Row][-1]
    }

    $Sum += $Ext

    foreach ($Row in $Rows) {$Row -join " "}
    $Ext
}

$Sum