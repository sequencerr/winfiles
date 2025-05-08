# Self-elevating administrator rights https://stackoverflow.com/a/63344749
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal] $identity
if (-not $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )) {
    $self = "-NoProfile -NoLogo -NoExit -File `"$($MyInvocation.MyCommand.Path)`" `"$($MyInvocation.MyCommand.UnboundArguments)`""
    Start-Process -PassThru -FilePath PowerShell.exe -ArgumentList $self -Verb Runas
    # Exiting PowerShell Terminal. https://stackoverflow.com/a/74359978
    return [System.Environment]::Exit(0)
}

Write-Host "Sourcing individual functions..."
Set-Location "$($MyInvocation.MyCommand.Path | Split-Path -Parent)"
Get-ChildItem .\functions\util -File | ForEach-Object { . $_.FullName }
Get-ChildItem .\functions -File | ForEach-Object { . $_.FullName }

Write-Host "Starting functions execution..."
Invoke-WUDO_P2P_Disable
Install-WindowsUpdatesAndReboot "$($MyInvocation.MyCommand.Path)"
Install-HelpUpdates
Invoke-UpdatesDisable

Invoke-AppsUninstall
Invoke-PrivacyHarden
Invoke-StartMenuTweaksApply
Invoke-TaskBarTweaksApply
Invoke-ExplorerTweaksApply
Invoke-TaskManagerTweaksApply
Invoke-VisualEffectsTweaksApply
Invoke-PersonalizationTweaksApply

Restart-Computer
