$numbers = @{
    "one" = 1
    "two" = 2
    "three" = 3
    "four" = 4
    "five" = 5
    "six" = 6
    "seven" = 7
    "eight" = 8
    "nine" = 9
    }

function ConvertToInt {
    param ($string)

    [Int]$Out = $null

    if ([Int]::TryParse($string, [ref]$Out)) {
        $retval = $Out
    } else {
        $retval = $numbers[$string]
    }

    $retval
}

$sum = 0
Get-Clipboard | %{
    $m = $_ | Select-String -Pattern '(?=(\d|one|two|three|four|five|six|seven|eight|nine))' -AllMatches
    $s = "{0}{1}" -f (ConvertToInt $m.matches[0].Groups[1].value), (ConvertToInt $m.matches[-1].Groups[1].value)
    Write-Host $s
    $sum += [int]$s
}
$sum

