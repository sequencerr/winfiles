function Invoke-OneDriveUninstall {
    $OneDrivePath = $($env:OneDrive)
    $regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\OneDriveSetup.exe"
    if (!(Test-Path $regPath)) { Write-Host "OneDrive is not installed." -ForegroundColor Red; return }

    Write-Host "Removing OneDrive..."
    $uninstallExe, $uninstallArgs = (Get-ItemPropertyValue "$regPath" -Name "UninstallString").Split(" ")
    Start-Process -FilePath $uninstallExe -ArgumentList "$uninstallArgs /silent" -NoNewWindow -Wait
    if (Test-Path $regPath) {
        Write-Host "Something went Wrong during the Unistallation of OneDrive" -ForegroundColor Red
        return
    }

    Write-Host "Copying downloaded Files from the OneDrive Folder to Root UserProfile"
    Start-Process -FilePath powershell -ArgumentList "robocopy '$($OneDrivePath)' '$($env:USERPROFILE.TrimEnd())\' /mov /e /xj" -NoNewWindow -Wait

    Write-Host "Removing OneDrive leftovers..."
    Remove-Item "$env:LocalAppData\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:LocalAppData\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:ProgramData\Microsoft OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "$env:SystemDrive\OneDriveTemp" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "HKCU:\SOFTWARE\Microsoft\OneDrive" -Recurse -Force -ErrorAction SilentlyContinue
    if ((Get-ChildItem "$OneDrivePath" -Recurse | Measure-Object).Count -eq 0) {
        # check if directory is empty before removing:
        Remove-Item "$OneDrivePath" -Recurse -Force -ErrorAction SilentlyContinue
    } else {
        Write-Host "Please Note - The OneDrive folder at $OneDrivePath may still have items in it. You must manually delete it, but all the files should already be copied to the base user folder."
        Write-Host "If there are Files missing afterwards, please Login to OneDrive.com and Download them manually" -ForegroundColor Yellow
    }

    Write-Host "Removing OneDrive from explorer sidebar..."
    Set-RegistryValue -Path "Registry::HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0 -ErrorAction SilentlyContinue
    Set-RegistryValue -Path "Registry::HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" -Name "System.IsPinnedToNameSpaceTree" -Value 0 -ErrorAction SilentlyContinue

    Write-Host "Removing run hook for new users..."
    reg load "hku\Default" "C:\Users\Default\NTUSER.DAT"
    reg delete "HKEY_USERS\Default\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "OneDriveSetup" /f
    reg unload "hku\Default"

    Write-Host "Removing StartMenu entry..."
    Remove-Item "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\OneDrive.lnk" -Force -ErrorAction SilentlyContinue

    Write-Host "Removing scheduled task..."
    Get-ScheduledTask -TaskPath '\' -TaskName 'OneDrive*' -ea SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

    # Add Shell folders restoring default locations
    Write-Host 'Fixing "User Shell Folders"...'
    $reg = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    Set-RegistryValue -Name "AppData"       -Value "%USERPROFILE%\AppData\Roaming" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "Cache"         -Value "%USERPROFILE%\AppData\Local\Microsoft\Windows\INetCache" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "Cookies"       -Value "%USERPROFILE%\AppData\Local\Microsoft\Windows\INetCookies" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "Desktop"       -Value "%USERPROFILE%\Desktop" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "Favorites"     -Value "%USERPROFILE%\Favorites" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "History"       -Value "%USERPROFILE%\AppData\Local\Microsoft\Windows\History" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "Local AppData" -Value "%USERPROFILE%\AppData\Local" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "My Music"      -Value "%USERPROFILE%\Music" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "My Pictures"   -Value "%USERPROFILE%\Pictures" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "{0DDD015D-B06C-45D5-8C4C-F59713854639}" -Value "%USERPROFILE%\Pictures" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "My Video"      -Value "%USERPROFILE%\Videos" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "NetHood"       -Value "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Network Shortcuts" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "Personal"      -Value "%USERPROFILE%\Documents" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "{F42EE2D3-909F-4907-8871-4C22FC0BF756}" -Value "%USERPROFILE%\Documents" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "PrintHood"     -Value "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Printer Shortcuts" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "Programs"      -Value "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "Recent"        -Value "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Recent" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "SendTo"        -Value "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\SendTo" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "Start Menu"    -Value "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "Startup"       -Value "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "Templates"     -Value "%USERPROFILE%\AppData\Roaming\Microsoft\Windows\Templates" -Type ExpandString -Path $reg
    Set-RegistryValue -Name "{374DE290-123F-4565-9164-39C4925E467B}" -Value "%USERPROFILE%\Downloads" -Type ExpandString -Path $reg

    Invoke-RestartShell
}

function Invoke-OneDriveInstall {
    winget install Microsoft.OneDrive -e --accept-source-agreements --accept-package-agreements --silent-ArgumentList
}
