function Install-HelpUpdates {
    if (Test-Path "~\PowerShell-Help-Updates") { return }

    Write-Host "Installing Help updates..."
    Update-Help -Force -ErrorAction SilentlyContinue
    New-Item -ItemType "Directory" -Path "~\PowerShell-Help-Updates" -ErrorAction SilentlyContinue
    Save-Help -DestinationPath "~\PowerShell-Help-Updates" -ErrorAction SilentlyContinue
}

# https://stackoverflow.com/questions/15166839/powershell-reboot-and-continue-script
# https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/jj574130(v=ws.11)
function Install-WindowsUpdatesAndReboot {
    PARAM(
        [Parameter(Mandatory=$true)]
        [String]$scriptPath
    )

    if (!(Get-InstalledModule -Name "PSWindowsUpdate" -ErrorAction SilentlyContinue)) {
        Write-Host 'Installing "NuGet" module provider...'
        Install-PackageProvider -Name "NuGet" -Force

        Write-Host 'Installing "PSWindowsUpdate" module...'
        Install-Module -Name "PSWindowsUpdate" -Force
    }
    Write-Host "Installing updates..."
    Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot # We'll reboot later if needed
    Delete-DeliveryOptimizationCache -Force

    if (!(Get-WURebootStatus -Silent)) {
        Write-Host "Updates finished. Restart is *not* required. Continuing..."
        return
    }
    Write-Host "Updates finished. Restart is required. Registering the task..."

    # Just in case. Make sure the action is overwritten.
    if (Get-ScheduledTask -TaskName "ResumeWorkflow" -ErrorAction SilentlyContinue) {
        Write-Host "Unregistering scheduled task..."
        Unregister-ScheduledTask -TaskName "ResumeWorkflow" -Confirm:$False -ErrorAction SilentlyContinue
    }
    $ScriptBlock = {
        # First things first. Unregister for consequent reboots.
        if (Get-ScheduledTask -TaskName "ResumeWorkflow" -ErrorAction SilentlyContinue) {
            Write-Host "Unregistering scheduled task..."
            Unregister-ScheduledTask -TaskName "ResumeWorkflow" -Confirm:$False -ErrorAction SilentlyContinue
        }
        & "$scriptPath"
    }
    $EncodedCommand = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes(
        $ScriptBlock.ToString().Replace("`$scriptPath", "$scriptPath")
    ))

    $PowerShellArguments = "-WindowStyle Maximized -NoExit -NoProfile -NoLogo -ExecutionPolicy Bypass -EncodedCommand `"$EncodedCommand`""
    $PowerShellExecutable = [Diagnostics.Process]::GetCurrentProcess().Path
    $Action = New-ScheduledTaskAction -Execute $PowerShellExecutable -Argument $PowerShellArguments

    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -WakeToRun
    $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME

    Register-ScheduledTask -TaskName "ResumeWorkflow" -Action $Action -Settings $Settings -Trigger $Trigger -User $env:USERNAME -RunLevel Highest

    Restart-Computer
    exit
}

$services = @(
    "BITS"
    "wuauserv"
)

# https://github.com/ChrisTitusTech/winutil/blob/48f1c715840477fdb024268c2db857d9e023621b/functions/public/Invoke-WPFUpdatesdisable.ps1#L16-L19
# https://www.elevenforum.com/t/turn-on-or-off-windows-update-delivery-optimization-in-windows-11.3136/
# S-1-5-20 — NetworkService
# https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-security-identifiers#well-known-sids
function Invoke-WUDO_P2P_Disable {
    if (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config") { return }

    Write-Host 'Disable "Allow downloads from other PCs" (for Windows Updates)'

    Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" `
    -Name "DODownloadMode" -Value 0 -Type DWord

    # For SettingsApp local display.
    Set-RegistryValue -Path "Registry::HKEY_USERS\S-1-5-20\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Settings" `
    -Name "DownloadMode" -Value 0 -Type DWord
}

# Disabling automatic Windows Updates is not recommended.
function Invoke-UpdatesDisable {
    Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Type DWord -Value 1
    Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Type DWord -Value 1

    foreach ($service in $services) {
        # -ErrorAction SilentlyContinue ignore a service doesn't exist

        Write-Host "Setting $service StartupType to Disabled"
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType "Disabled"
    }
    Write-Host "================================="
    Write-Host "---   Updates ARE DISABLED    ---"
    Write-Host "================================="
}

function Invoke-UpdatesEnable {
    foreach ($service in $services) {
        # -ErrorAction SilentlyContinue ignore a service doesn't exist

        Write-Host "Setting $service StartupType to Automatic"
        Get-Service -Name $service -ErrorAction SilentlyContinue | Set-Service -StartupType "Automatic"
    }

    Write-Host "Enabling driver offering through Windows Update..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Device Metadata" -Name "PreventDeviceMetadataFromNetwork" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontPromptForWindowsUpdate" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DontSearchWindowsUpdate" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DriverSearching" -Name "DriverUpdateWizardWuSearchEnabled" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -ErrorAction SilentlyContinue
    Write-Host "Enabling Windows Update automatic restart..."
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUPowerManagement" -ErrorAction SilentlyContinue
    Write-Host "Enabled driver offering through Windows Update"
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "BranchReadinessLevel" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "DeferFeatureUpdatesPeriodInDays" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" -Name "DeferQualityUpdatesPeriodInDays" -ErrorAction SilentlyContinue
    Write-Host "==================================================="
    Write-Host "---  Windows Update Settings Reset to Default   ---"
    Write-Host "==================================================="

    # Start-Process -FilePath "secedit" -ArgumentList "/configure /cfg $env:WinDir\inf\defltbase.inf /db defltbase.sdb /verbose" -Wait
    # Start-Process -FilePath "cmd.exe" -ArgumentList "/c RD /S /Q $env:WinDir\System32\GroupPolicyUsers" -Wait
    # Start-Process -FilePath "cmd.exe" -ArgumentList "/c RD /S /Q $env:WinDir\System32\GroupPolicy" -Wait
    # Start-Process -FilePath "gpupdate" -ArgumentList "/force" -Wait
    # Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    # Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\WindowsSelfHost" -Recurse -Force -ErrorAction SilentlyContinue
    # Remove-Item -Path "HKCU:\SOFTWARE\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    # Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    # Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    # Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" -Recurse -Force -ErrorAction SilentlyContinue
    # Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\WindowsSelfHost" -Recurse -Force -ErrorAction SilentlyContinue
    # Remove-Item -Path "HKLM:\SOFTWARE\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    # Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    # Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Policies" -Recurse -Force -ErrorAction SilentlyContinue
    # Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\WindowsStore\WindowsUpdate" -Recurse -Force -ErrorAction SilentlyContinue

    # Write-Host "==================================================="
    # Write-Host "---  Windows Local Policies Reset to Default   ---"
    # Write-Host "==================================================="
}
