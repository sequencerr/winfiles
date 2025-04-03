# Self-elevating administrator rights https://stackoverflow.com/a/63344749
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal] $identity
if (-not $principal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )) {
    $self = "-NoProfile -NoLogo -NoExit -File `"$($MyInvocation.MyCommand.Path)`" `"$($MyInvocation.MyCommand.UnboundArguments)`""
    Start-Process -PassThru -FilePath PowerShell.exe -Verb Runas -ArgumentList $self
    # Exiting PowerShell Terminal. https://stackoverflow.com/a/74359978
    return [System.Environment]::Exit(0)
}

Write-Host "Installing updates..."
if (!(Test-Path "~\PowerShell-Help-Updates")) {
    Update-Help -Force -ErrorAction SilentlyContinue
    New-Item "~\PowerShell-Help-Updates" -ErrorAction SilentlyContinue
    Save-Help -DestinationPath "~\PowerShell-Help-Updates"
}
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSWindowsUpdate -Force
Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot # We'll reboot later if needed
Delete-DeliveryOptimizationCache -Force

if (Get-WURebootStatus -Silent) {
    # https://stackoverflow.com/questions/15166839/powershell-reboot-and-continue-script
    # https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/jj574130(v=ws.11)?redirectedfrom=MSDN
    if (Get-ScheduledTask -TaskName "ResumeWorkflow" -ErrorAction SilentlyContinue) {
        Write-Host "Unregistering scheduled task..."
        Unregister-ScheduledTask -TaskName "ResumeWorkflow" -Confirm:$False -ErrorAction SilentlyContinue
    }

    $PowerShellArguments = "-WindowStyle Maximized -NoExit -NoProfile -NoLogo -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`""
    $PowerShellExecutable = [Diagnostics.Process]::GetCurrentProcess().Path
    $Action = New-ScheduledTaskAction -Execute $PowerShellExecutable -Argument $PowerShellArguments

    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -WakeToRun
    $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

    Register-ScheduledTask -TaskName "ResumeWorkflow" -Action $Action -Settings $Settings -Trigger $Trigger -User $env:USERNAME -RunLevel Highest

    Restart-Computer
    exit
}

Write-Host "Sourcing individual functions..."
Set-Location "$($MyInvocation.MyCommand.Path | Split-Path -Parent)"
Get-ChildItem .\functions\util -File | ForEach-Object { . $_.FullName }
Get-ChildItem .\functions -File | ForEach-Object { . $_.FullName }

Write-Host "Starting functions execution..."
Invoke-UpdatesDisable
Invoke-AppsUninstall
Invoke-StartMenuTweaksApply
Invoke-TaskBarTweaksApply
Invoke-TaskManagerTweaksApply
Invoke-ExplorerTweaksApply
Invoke-PerfomanceOptionsDisable

Restart-Computer
