function Set-RegistryValue {
    PARAM ($Path, $Name, $Value, $Type)

    if (!(Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
    Set-ItemProperty -Path $Path `
    -Name $Name -Value $Value -Type $Type
}
