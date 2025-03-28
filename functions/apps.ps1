# Get-AppxPackage -AllUsers | Where-Object { (Get-AppxPackage $_.Name) -ne $null -and !(Get-AppxPackage $_.Name).NonRemovable } | Select Name, PackageFullName | Sort-Object { $_.Name }
$programs = @(
    "Microsoft.549981C3F5F10" # Cortana
    # "Microsoft.Advertising.Xaml"
    "Microsoft.BingSearch"
    "Microsoft.BingWeather"
    "Microsoft.Copilot"
    # "Microsoft.DesktopAppInstaller"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    # "Microsoft.HEIFImageExtension"
    "Microsoft.Microsoft3DViewer"
    # "Microsoft.MicrosoftEdge.Stable"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.MixedReality.Portal"
    "Microsoft.MSPaint" # Paint 3D, not Classic One
    "Microsoft.Office.OneNote"
    "Microsoft.OutlookForWindows"
    "Microsoft.People"
    "Microsoft.ScreenSketch"
    "Microsoft.SkypeApp"
    "Microsoft.StorePurchaseApp"
    "Microsoft.Wallet"
    "Microsoft.Windows.DevHome"
    # "Microsoft.WebMediaExtensions"
    # "Microsoft.WebpImageExtension"
    "Microsoft.Windows.Photos"
    "Microsoft.WindowsAlarms"
    # "Microsoft.WindowsCalculator"
    "Microsoft.WindowsCamera"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.WindowsStore"
    # "Microsoft.Winget.Source"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
)

# Get-WindowsOptionalFeature -Online | ?{ $_.State -eq 'Enabled' } | %{ '"' + $_.FeatureName + '"'}
$optional = @(
    "WindowsMediaPlayer"
    "Internet-Explorer-Optional-amd64"
)

# https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-capabilities-package-servicing-command-line-options?view=windows-11#get-capabilities
# DISM - Deployment Image Servicing and Management
# DISM /Online /Remove-Capability /CapabilityName:Microsoft.Windows.WordPad~~~~0.0.1.0
$lines = (DISM /Online /Get-Capabilities).Split("`r`n")
$capabilities = @()
for ($i = 8; $i -lt $lines.Length - 1 - 2; $i += 3) {
    $capabilities += [PSCustomObject]@{
        CapabilityIdentity = $lines[$i].Trim() -replace "Capability Identity : ", ""
        State = $lines[$i + 1].Trim() -replace "State : ", ""
    }
}
# $capabilities | ?{ $_.State -eq "Installed" }
$caps = @(
    "App.StepsRecorder~~~~0.0.1.0"
    "App.Support.ContactSupport~~~~0.0.1.0"
    "App.Support.QuickAssist~~~~0.0.1.0"
    "Browser.InternetExplorer~~~~0.0.11.0"
    # "DirectX.Configuration.Database~~~~0.0.1.0"
    "Hello.Face.18967~~~~0.0.1.0"
    # "Language.Basic~~~en-US~0.0.1.0"
    "Language.Handwriting~~~en-US~0.0.1.0"
    # "Language.OCR~~~en-US~0.0.1.0"
    # "Language.Speech~~~en-US~0.0.1.0"
    # "Language.TextToSpeech~~~en-US~0.0.1.0"
    "MathRecognizer~~~~0.0.1.0"
    "Media.WindowsMediaPlayer~~~~0.0.12.0"
    "Microsoft.Windows.MSPaint~~~~0.0.1.0"
    "Microsoft.Windows.Notepad~~~~0.0.1.0"
    "Microsoft.Windows.PowerShell.ISE~~~~0.0.1.0"
    "Microsoft.Windows.WordPad~~~~0.0.1.0"
    "OneCoreUAP.OneSync~~~~0.0.1.0" # Sync engine used by UWP apps like Mail, Calendar and People.
    "OpenSSH.Client~~~~0.0.1.0"
    "Print.Fax.Scan~~~~0.0.1.0"
    # "Print.Management.Console~~~~0.0.1.0"
    # "Windows.Client.ShellComponents~~~~0.0.1.0"
)

# Get-WindowsPackage -Online | Select PackageName, PackageState, ReleaseType
$pkgsMatch = @(
    "Microsoft-Windows-UserExperience-Desktop-Package~31bf3856ad364e35~" # Windows Backup App
)
$pkgs = Get-WindowsPackage -Online | ForEach-Object { $_.PackageName } | Where-Object {
    foreach ($start in $pkgsMatch) {
        if ($_.StartsWith($start)) { return $true }
    }
    return $false
}

function Invoke-AppsUninstall {
    foreach ($program in $programs) {
        if ($null -eq (Get-AppxPackage -Name $program)) { continue }
        if ((Get-AppxPackage -Name $program).NonRemovable) { Write-Error "Program $program is `"NonRemovable`""; return }
        Write-Host "Removing $program..."
        Get-AppxPackage -Name $program | Remove-AppxPackage
        Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq $program | Remove-AppxProvisionedPackage -Online
    }
    $assoc = Get-Item -Path "HKLM:\SOFTWARE\Classes\SystemFileAssociations"
    foreach ($ext in $assoc.GetSubKeyNames()) {
        if ($null -eq $assoc.OpenSubKey("$ext\Shell\3D Edit")) { continue }
        Write-Host "Removing 'Edit with Paint 3D' from context menu for `"$ext`" extension..."
        Remove-Item -Path "HKLM:\SOFTWARE\Classes\SystemFileAssociations\$ext\Shell\3D Edit" -Recurse -Force -ErrorAction SilentlyContinue
    }

    $jobs = @()
    foreach ($feat in $optional) {
        $job = Start-Job -ArgumentList $feat -ScriptBlock {
            PARAM ($feat)

            $featFound = Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq $feat }
            if ($null -eq $featFound -or "Disabled" -eq $featFound.State) { return }
            Write-Host "Removing $feat..."
            Disable-WindowsOptionalFeature -Online -FeatureName "$feat" -NoRestart
        }
        Write-Host "$($job.Name) Started for feature: $feat"
        $jobs += $job
    }

    foreach ($cap in $caps) {
        $job = Start-Job -ArgumentList $cap -ScriptBlock {
            PARAM ($cap)

            # DISM /Online /Get-CapabilityInfo /CapabilityName:"$cap"
            $out = DISM /Online /Remove-Capability /CapabilityName:"$cap" /NoRestart
            if ($out[9] -eq "A Windows capability name was not recognized.") { return }
            Write-Host "Removed $cap.`n$($out[-1])"
        }
        Write-Host "$($job.Name) Started for capability: $cap"
        $jobs += $job
    }

    foreach ($pkg in $pkgs) {
        $job = Start-Job -ArgumentList $pkg -ScriptBlock {
            PARAM ($pkg)

            Write-Host "Removing $pkg..."
            Remove-WindowsPackage -Online -PackageName $pkg -NoRestart
        }
        Write-Host "$($job.Name) Started for package: $pkg"
        $jobs += $job
    }

    if ($jobs.Count -gt 0) {
        Write-Host "Waiting $($jobs.Count) jobs..."
        Wait-Job -Job $jobs | Out-Null
        Write-Host "Stopping $($jobs.Count) jobs..."
        Remove-Job -Job $jobs
    }

    Invoke-EdgeBrowserUninstall
    Invoke-OneDriveUninstall
}
