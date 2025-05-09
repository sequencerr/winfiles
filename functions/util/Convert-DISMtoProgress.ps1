function Convert-DISMtoProgress {
    PARAM($log, $cmd)

    $log

    $msgErr = @()
    $parts = $cmd -split '\s+'
    & $parts[0] @($parts[1..($parts.Length-1)]) | ForEach-Object { $i = 0 }{
        if ($i++ -lt 7) { return }
        if ($_ -match "^\[[= ]+(\d+.\d+)%[= ]+]") {
            $percent = [int]$Matches[1]
            Write-Progress -PercentComplete $percent -Activity $log
            return
        }
        if ($msgErr.Length -or $_.StartsWith("Error: ")) { $msgErr += "$_"; return }
        # if ($percent -ge 100) { Write-Host $_ }
    }

    if ($msgErr.Length) { Write-Error ($msgErr -join "`n") }
}
