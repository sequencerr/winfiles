function New-TempPath {
    $newName = Join-Path ([System.IO.Path]::GetTempPath()) (New-Guid).ToString("N")
    New-Item -ItemType Directory -Path $newName | Out-Null
    return $newName
}
