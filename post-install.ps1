Get-ChildItem .\functions\ -File | ForEach-Object { . $_.FullName }

Invoke-UpdatesDisable

Invoke-EdgeBrowserUninstall
Invoke-OneDriveUninstall

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

# https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/dism-capabilities-package-servicing-command-line-options?view=windows-11#get-capabilities
# DISM - Deployment Image Servicing and Management
# DISM /Online /Remove-Capability /CapabilityName:Microsoft.Windows.WordPad~~~~0.0.1.0
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
foreach ($cap in $caps) {
    # DISM /Online /Get-CapabilityInfo /CapabilityName:"$cap"
    DISM /Online /Remove-Capability /CapabilityName:"$cap" /NoRestart
}
