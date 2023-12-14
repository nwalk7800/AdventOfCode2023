function GetDistance {
    param (
        $Galaxy1,
        $Galaxy2,
        $ExpansionRate = 2
    )

    $Expansion = 0

    foreach ($Row in $EmptyRows) {
        if ($Row -in $Galaxy1[0]..$Galaxy2[0]) {
            $Expansion++
        }
    }
        
    foreach ($Col in $EmptyCols) {
        if ($Col -in $Galaxy1[1]..$Galaxy2[1]) {
            $Expansion++
        }
    }
        
    $Distance = [Math]::Abs($Galaxy1[0] - $Galaxy2[0]) + [Math]::Abs($Galaxy1[1] - $Galaxy2[1])
    $Distance += ($Expansion * $ExpansionRate) - $Expansion
    $Distance
}

$InMap = Get-Clipboard | ?{$_ -ne ""}

$Map = New-Object System.Collections.ArrayList

$EmptyRows = @()
$RowNum = 0
foreach ($Row in $InMap) {
    $Map.Add((New-Object System.Collections.ArrayList)) | Out-Null
    $Row = $Row -split "" | ?{$_ -ne ""}
    $Map[-1].AddRange($Row)
    if (($Row | select -Unique).Count -eq 1) {
        $EmptyRows += $RowNum
    }
    $RowNum++
}

#Find Empty Columns
$EmptyCols = @()
foreach ($Col in 0..$Map[0].Count) {
    $Empty = $true
    foreach ($Row in $Map) {
        $Empty = $Empty -and $Row[$Col] -eq "."
    }

    if ($Empty) {
        $EmptyCols += $Col
    }
}

#Find Galaxies
$Galaxies = @{}
$Galaxy = 0
for ($Row = 0; $Row -lt $Map.Count; $Row++) {
    for ($Col = 0; $Col -lt $Map[$Row].Count; $Col++) {
        if ($Map[$Row][$Col] -eq "#") {
            $Galaxies[$Galaxy] = @($Row,$Col) 
            $Galaxy++
        }
    }
}

#Find Pairs
$Pairs = @{}
foreach ($Galaxy in $Galaxies.Keys) {
    for ($Pair = $Galaxy+1; $Pair -lt $Galaxies.Count; $Pair++) {
        $Distance = GetDistance $Galaxies[$Galaxy] $Galaxies[$Pair]
        $Pairs[$Galaxy,$Pair -join ","] = $Distance
    }
}

$TotalDistance = 0
foreach ($Pair in $Pairs.Keys) {
    $TotalDistance += $Pairs[$Pair]
}

$TotalDistance