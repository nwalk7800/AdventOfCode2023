class Range {
    [Int64] $Begin
    [Int64] $End

    Range([Int64]$Begin, [Int64]$End) {
        $this.Begin = $Begin
        $this.End = $End
    }

    static [Range[]] Merge([Range[]]$Ranges) {
        $Result = @()

        if ($Ranges.Count -gt 1) {
            $Result = $Ranges[0]

            for ($ndx = 1; $ndx -lt $Ranges.Count; $ndx++) {
                $Result = [Range]::Add($Result, $Ranges[$ndx])
            }
        } else {
            $Result = $Ranges
        }

        return $Result
    }

    static [Range[]] Add([Range[]]$Ranges1, [Range[]]$Ranges2) {
        $Result = $null
        
        if ($Ranges1 -eq $null) {
            $Result = $Ranges2.Clone()
        } elseif ($Ranges2 -eq $null) {
            $Result = $Ranges1.Clone()
        } elseif ($Ranges1.Count -gt 1 -or $Ranges2.Count -gt 1) {
            foreach ($Range1 in $Ranges1) {
                foreach ($Range2 in $Ranges2) {
                    $Result = [Range]::Subtract($Range1, $Range2)
                }
            }
        } else {
            $Range1 = $Ranges1[0]
            $Range2 = $Ranges2[0]

            if ($Range1 -eq $null) {
                $Result = $Range2.Clone()

            } elseif ($Range2 -eq $null) {
                $Result = $Range1.Clone()

            } elseif ($Range1.End -eq $Range2.Begin - 1) {
                # Range2 immediately follows Range1
                $Result = New-Object Range $Range1.Begin, $Range2.End

            } elseif ($Range2.End -eq $Range1.Begin - 1) {
                # Range2 immediately follows Range1
                $Result = New-Object Range $Range2.Begin, $Range1.End

            } elseif ($Range1.End -lt $Range2.Begin -or $Range1.Begin -gt $Range2.End) {
                # They don't touch, return two Ranges
                $Result = $Range1.Clone(), $Range2.Clone()

            } elseif ($Range1.Begin -ge $Range2.Begin -and $Range1.Begin -le $Range2.End) {
                if ($Range1.End -le $Range2.End) {
                    # Range1 is completely within Range2
                    $Result = $Range2.Clone()

                } elseif ($Range1.End -gt $Range2.End) {
                    # Range1 Starts in $Range2 and ends outside
                    $Result = New-Object Range $Range2.Begin, $Range1.End

                }
            } elseif ($Range2.Begin -ge $Range1.Begin -and $Range2.Begin -le $Range1.End) {
                # Range2 starts in Range1 and ends after
                $Result = New-Object Range $Range1.Begin, $Range2.End

            } elseif ($Range2.Begin -ge $Range1.Begin -and $Range2.End -le $Range1.End) {
                # Range2 is completely within Range1
                $Result = $Range1.Clone()
            }
        }
        return $Result
    }

    static [Range[]] Subtract([Range[]]$Ranges1, [Range[]]$Ranges2) {
        $Result = @()
        
        if ($Ranges1 -eq $null -or $Ranges2 -eq $null) {
            $Result = $Ranges1.Clone()
        } elseif ($Ranges1.Count -gt 1 -or $Ranges2.Count -gt 1) {
            foreach ($Range1 in $Ranges1) {
                foreach ($Range2 in $Ranges2) {
                    $Result += [Range]::Subtract($Range1, $Range2)
                }
            }
        } else {
            $Range1 = $Ranges1[0]
            $Range2 = $Ranges2[0]

            if ($Range1 -eq $null) {
                $Result = $null

            } elseif ($Range2 -eq $null) {
                $Result = $Range1.Clone()

            } elseif ($Range1.End -lt $Range2.Begin -or $Range1.Begin -gt $Range2.End) {
                # They don't touch, return two Ranges
                $Result = $Range1.Clone()

            } elseif ($Range1.Begin -ge $Range2.Begin -and $Range1.Begin -le $Range2.End) {
                if ($Range1.End -le $Range2.End) {
                    # Range1 is completely within Range2
                    $Result = $null

                } elseif ($Range1.End -gt $Range2.End) {
                    # Range1 Starts in $Range2 and ends outside
                    $Result = New-Object Range ($Range2.End + 1), $Range1.End

                }
            } elseif ($Range1.End -ge $Range2.Begin -and $Range1.End -le $Range2.End) {
                # Range1 ends inside Range2, but starts before
                $Result = New-Object Range $Range1.Begin, ($Range2.Begin - 1)

            } elseif ($Range2.Begin -ge $Range1.Begin -and $Range2.End -le $Range1.End) {
                # Range2 is completely within Range1
                $Result = (New-Object Range $Range1.Begin, ($Range2.Begin - 1)),
                          (New-Object Range ($Range2.End + 1), $Range1.End)
            }
        }
        return $Result
    }

    [Range] Clone() {
        return New-Object Range $this.Begin, $this.End
    }
}

$Sections = ((Get-Clipboard) -join "`n") -split "`n`n"

$Seeds = @()
$MapOrder = @{}
$Maps = @{}

function GetRangeOverlap {
    param (
        $Range1,
        $Range2
    )

    if ($Range1.Begin -ge $Range2.Begin -and $Range1.Begin -le $Range2.End) {
        if ($Range1.End -le $Range2.End) {
            # Range1 is completely within Range2
            $Range1.Clone()
        } elseif ($Range1.End -gt $Range2.End) {
            # Range1 Starts in $Range2 and ends outside
            New-Object Range $Range1.Begin, $Range2.End
        }
    } elseif ($Range1.End -ge $Range2.Begin -and $Range1.End -le $Range2.End) {
        # Range1 ends inside Range2, but starts before
        New-Object Range $Range2.Begin, $Range1.End
    } elseif ($Range2.Begin -ge $Range1.Begin -and $Range2.End -le $Range1.End) {
        # Range2 is completely within Range1
        New-Object Range $Range2.Begin, $Range2.End
    }
}

function MapSection {
    param (
        $Section
    )

    $SectionName, $SectionData = $Section -split ":"
    $MapName = ($SectionName -split " ")[0]

    $Maps[$MapName] = @()
    foreach ($Line in ($SectionData -split "`n" | select -Skip 1)) {
        $Range = "" | select SrcRange, Offset
        [Int64]$DstStart, [Int64]$SrcStart, [Int64]$Length = $Line.Trim() -split " "
        
        $Range.Offset = $DstStart - $SrcStart
        $Range.SrcRange = New-Object Range $SrcStart, ($SrcStart + $Length - 1)
        $Maps[$MapName] += $Range
    }

    $MapName
}

function TranslateMap {
    param (
        $SourceRanges,
        $Map
    )

    $Overlaps = $null
    $MinLocation = [Int64]::MaxValue
    foreach ($SourceRange in $SourceRanges) {
        $RangeOverlaps = @()
        $UnmodOverlaps = @()
        foreach ($Range in $Maps[$MapOrder[$Map]]) {
            $Overlaps = GetRangeOverlap $SourceRange $Range.SrcRange
            
            if ($Overlaps) {
                $UnmodOverlaps = [Range]::Add($UnmodOverlaps, $Overlaps)
            }
            
            foreach ($Overlap in $Overlaps) {
                $Overlap.Begin += $Range.Offset
                $Overlap.End += $Range.Offset
            }

            $RangeOverlaps = [Range]::Add($RangeOverlaps, $Overlaps)
        }        
        
        $Unmatched = [Range]::Subtract($SourceRange, $UnmodOverlaps)


        if ($Map -eq 6) {
                foreach ($DstRange in $Unmatched) {
                    $MinLocation = [Math]::Min($MinLocation, $DstRange.Begin)
                }
                foreach ($DstRange in $RangeOverlaps) {
                    $MinLocation = [Math]::Min($MinLocation, $DstRange.Begin)
                }
                
        } else {
            foreach ($Overlap in $RangeOverlaps) {
                $MinLocation = [Math]::Min($MinLocation, (TranslateMap $Overlap ($Map + 1)))
            }

            $MinLocation = [Math]::Min($MinLocation, (TranslateMap $Unmatched ($Map + 1)))
        }

    }
    if ($MinLocation -le 0) {
        [Int64]::MaxValue
    } else {
        $MinLocation
    }
}

$SectionName, $SectionData = $Sections[0] -split ":"
$SeedRangesString = ($SectionData.Trim() | Select-String -Pattern "\d+ \d+" -AllMatches).Matches.Value
$SeedRanges = @()
foreach ($SeedRange in $SeedRangesString) {
    [Int64]$Start, [Int64]$Length = $SeedRange -split " "
    $SeedRanges += New-Object Range $Start, ($Start + $Length - 1)
}

$ndx = 0
foreach ($Section in $Sections[1..$Sections.Length]) {
    $MapName = MapSection -Section $Section
    $MapOrder[$ndx++] = $MapName
}

$Found = $false
TranslateMap $SeedRanges 0