function Invoke-EdgeBrowserUninstall {
    if (!(Test-Path -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge")) { Write-Host "Edge is not installed." -ForegroundColor Red;; return }

    $pathEdgeExe = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe")."(Default)"

    # for some reason needed for uninstaller(UninstallString). without this, uninstaller silently exists
    $pathEdgeUWP = "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe"
    New-Item "$pathEdgeUWP" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    New-Item "$pathEdgeUWP\MicrosoftEdge.exe" -ErrorAction SilentlyContinue | Out-Null

    # Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdateDev" -Name AllowUninstall -Value '' -ErrorAction SilentlyContinue
    # Set-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge\EdgeUpdate\ClientState\{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}" -Name experiment_control_labels -Value '' -ErrorAction SilentlyContinue # it was on old versions, instead EdgeUpdateDev.AllowUninstall

    $uninstallString = (Get-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge").UninstallString + " --force-uninstall --delete-profile"
    Start-Process cmd.exe "/c $uninstallString" -WindowStyle Hidden -Wait

    # EdgeUWP(Universal Windows Platform) is removed in latest patch of Windows. Before it broke Windows updates, if removal not handled correctly.
    Remove-Item "$pathEdgeUWP" -Recurse -ErrorAction SilentlyContinue | Out-Null

    # Leftovers
    # Note: The Microsoft Edge Update service might remain, this is normal as it is required for updating WebView2.
    Remove-Item -Path "Computer\\HKEY_CLASSES_ROOT\\MSEdgePDF" -ErrorAction SilentlyContinue | Out-Null
    Remove-Item -Path "Computer\\HKEY_CLASSES_ROOT\\MSEdgeHTM" -ErrorAction SilentlyContinue | Out-Null
    Remove-Item -Path "Computer\\HKEY_CLASSES_ROOT\\MSEdgeMHT" -ErrorAction SilentlyContinue | Out-Null
    Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Edge" -Recurse -ErrorAction SilentlyContinue | Out-Null
    Remove-Item -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Edge" -Recurse -ErrorAction SilentlyContinue | Out-Null

    $sh = New-Object -ComObject WScript.Shell
    foreach ($shortcut in (Get-ChildItem -Path ([Environment]::GetFolderPath("Desktop")) -File -Filter "*.lnk")) {
        try {
            if ($pathEdgeExe -ne $sh.CreateShortcut($shortcut.FullName).TargetPath) { continue }
            Write-Host "Found shortcut on desktop: $($shortcut.FullName)"
            Remove-Item "$($shortcut.FullName)"
        } catch {
            Write-Host "Failed to read shortcut target for: $($shortcut.FullName)"
        }
    }

    # https://answers.microsoft.com/en-us/microsoftedge/forum/all/blue-icon-ghost-edge-messing-default-programs/363390f2-6b89-4598-a97c-bc61f7b84cf6
    # /\ little bit different story but got some clues. I had ghost StartMenu and App&Features item
    # https://github.com/microsoft/winget-cli/discussions/844#discussioncomment-4633738
    # doesn't work - "Set-NonRemovableAppsPolicy -Online -PackageFamilyName (Get-AppxPackage -Name "Microsoft.MicrosoftEdge" -AllUsers).PackageFamilyName -NonRemovable 0" - https://learn.microsoft.com/en-us/powershell/module/dism/set-nonremovableappspolicy?view=windowsserver2025-ps

    Write-Host "Edge Stable has been successfully uninstalled"
}

function Invoke-EdgeInstall {
    $tmpEdgePath = (New-Item -ItemType Directory -Path (Join-Path ([System.IO.Path]::GetTempPath()) (New-Guid).ToString("N"))).FullName + "\MicrosoftEdgeSetup.exe"

    try {
        Write-Host "Installing Edge ..."
        Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2109047&Channel=Stable&language=en&consent=1" -OutFile $tmpEdgePath
        Start-Process -FilePath $tmpEdgePath -ArgumentList "/silent /install" -Wait
        Remove-item $tmpEdgePath
        Write-Host "Edge Installed Successfully"
    } catch {
        Write-Host "Failed to install Edge"
    }
}
