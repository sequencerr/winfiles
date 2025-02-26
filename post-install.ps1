Get-ChildItem .\functions\ -File | ForEach-Object { . $_.FullName }

Invoke-UpdatesDisable

Invoke-EdgeBrowserUninstall

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

# Get-WindowsOptionalFeature -Online | ?{ $_.State -eq 'Enabled' } | %{ '"' + $_.FeatureName + '"'}
$optional = @(
    "WindowsMediaPlayer"
    "Internet-Explorer-Optional-amd64"
)
foreach ($feat in $optional) {
    if ("Disabled" -eq (Get-WindowsOptionalFeature -Online | Where-Object { $_.FeatureName -eq $feat }).State) { continue }
    Write-Host "Removing $feat..."
    Disable-WindowsOptionalFeature -Online -FeatureName "$feat" -NoRestart
}
