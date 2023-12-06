$Sections = ((Get-Clipboard) -join "`n") -split "`n`n"

$Seeds = @()
$Maps = @{}

function MapSection {
    param (
        $SrcList,
        $Section
    )

    $SectionName, $SectionData = $Section -split ":"
    $MapName = ($SectionName -split " ")[0]

    $Maps[$MapName] = @{}
    $Ranges = @()
    foreach ($Line in ($SectionData -split "`n" | select -Skip 1)) {
        $Range = "" | select DstStart, SrcStart, Length
        [Int64]$Range.DstStart, [Int64]$Range.SrcStart, [Int64]$Range.Length = $Line.Trim() -split " "
        $Ranges += $Range
    }

    foreach ($Source in $SrcList) {
        $Maps[$MapName][$Source] = $Source
        foreach ($Range in $Ranges) {
            if ($Source -ge $Range.SrcStart -and $Source -le $Range.SrcStart + $Range.Length) {
                $Offset = $Range.DstStart - $Range.SrcStart
                $Maps[$MapName][$Source] = $Source + $Offset
                break
            }
        }
    }

    $MapName
}

$SectionName, $SectionData = $Sections[0] -split ":"
$Seeds = $SectionData.Trim() -split " " | %{[Int64]$_}
$PrevList = $Seeds

foreach ($Section in $Sections[1..$Sections.Length]) {
    $MapName = MapSection -SrcList $PrevList -Section $Section
    $PrevList = $Maps[$MapName].Values
}

($PrevList | measure -Minimum).Minimum