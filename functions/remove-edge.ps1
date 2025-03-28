function Invoke-EdgeBrowserUninstall {
    if (!(Test-Path -Path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge")) { Write-Host "Edge is not installed." -ForegroundColor Red; return }

    $pathEdgeExe = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\msedge.exe")."(Default)"

    # needed for uninstaller
    $pathEdgeUWP = "$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe"
    New-Item "$pathEdgeUWP" -ItemType Directory -ErrorAction SilentlyContinue | Out-Null
    New-Item "$pathEdgeUWP\MicrosoftEdge.exe" -ErrorAction SilentlyContinue | Out-Null

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

    Write-Host "Edge Stable has been successfully uninstalled"
}

function Invoke-EdgeInstall {
    $tmpEdgePath = $(New-TempPath) + "\MicrosoftEdgeSetup.exe"

    try {
        Write-Host "Installing Edge ..."
        Invoke-WebRequest -Uri "https://go.microsoft.com/fwlink/?linkid=2109047&Channel=Stable&language=en&consent=1" -OutFile $tmpEdgePath
        Start-Process -FilePath $tmpEdgePath -ArgumentList "/silent /install" -Wait
        Remove-item $tmpEdgePath
        Write-Host "Edge Installed Successfully"
    } catch {
        Write-Host "Failed to install Edge"
        Write-Error $_ | Select *
    }
}
