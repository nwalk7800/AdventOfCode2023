$Data = Get-Clipboard
[Int64]$Time = ($Data[0].Split(" ", [StringSplitOptions]::RemoveEmptyEntries) | select -Skip 1) -join ""
[Int64]$Dist = ($Data[1].Split(" ", [StringSplitOptions]::RemoveEmptyEntries) | select -Skip 1) -join ""
$Wins = @()

$StartVal = [Math]::Ceiling($Dist / $Time)

while ($StartVal * ($Time - $StartVal) -le $Dist) {
    $StartVal += 10
}

while ($StartVal * ($Time - $StartVal) -gt $Dist) {
    $StartVal--
}
$StartVal++

$Win = 0
for ($HoldTime = $StartVal; $HoldTime * ($Time - $HoldTime) -gt $Dist; $HoldTime += 100) {
    $Win += 100
}

for ($HoldTime = $HoldTime; $HoldTime * ($Time - $HoldTime) -lt $Dist; $HoldTime--) {
    $Win--
}

$Win + 1