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
    # "Microsoft.MSPaint"
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
    if ((Get-AppxPackage -Name $program).NonRemovable) { Write-Error "$program is `"NonRemovable`""; return }
    Write-Output "Removing $program..."
    Get-AppxPackage -Name $program | Remove-AppxPackage
    Get-AppxProvisionedPackage -Online | Where-Object DisplayName -eq $program | Remove-AppxProvisionedPackage -Online
}
