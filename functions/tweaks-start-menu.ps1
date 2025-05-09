# https://quake.blog/configure-windows-11-start-menu-using-only-group-policy.html
# https://stackoverflow.com/questions/75303803/how-to-remove-all-pinned-apps-in-windows-11-start-menu-using-powershell
# https://superuser.com/questions/1704373/automatically-unpin-applications-every-logon
# https://superuser.com/questions/1765044/remove-all-pinned-apps-in-start-menu-using-power-shell
# https://superuser.com/questions/1689313/is-there-any-way-to-remove-certain-pinned-apps-links-from-windows-11-taskbar

# https://winpeguy.wordpress.com/2015/12/09/win10-start-menu-cleanup-using-defaultlayouts-xml/
# https://www.tenforums.com/customization/21002-how-automatically-cmd-powershell-script-unpin-all-apps-start.html
# https://gist.github.com/sheldonhull/0fbe0840ecbdd1d1d95563fd3e63d449
# https://www.reddit.com/r/PowerShell/comments/jfy9fm/script_to_unpin_folder_from_start_menu/
# https://github.com/Sycnex/Windows10Debloater/blob/a48b4d8dc501680e0edc31f840791c966d89d309/Windows10DebloaterGUI.ps1#L1370

# https://techcommunity.microsoft.com/discussions/windowspowershell/start-menu-unpin-shortcuts-via-powershell-script/2961993
# https://superuser.com/a/1442733
# https://learn.microsoft.com/en-us/windows/configuration/start/layout?tabs=gpo%2Cintune-11&pivots=windows-10
function Invoke-StartMenuTilesRemove {
    if ((Get-CimInstance -Class Win32_OperatingSystem).Caption -Match "Windows 11") { Write-Host "Windows 11 isn't supported. yet"; return }
    Write-Host "StartMenu: Applying empty layout"

    # Export-StartLayout -UseDesktopApplicationID -Path "C:\StartMenuLayout.xml"
    $layoutFile = @"
<LayoutModificationTemplate `
xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" `
xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" `
Version="1" `
xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@
    $layoutFilePath = $(New-TempPath) + "\StartMenuLayout.xml"
    Write-Output $layoutFile | Out-File $layoutFilePath -Encoding ASCII

    # https://learn.microsoft.com/en-us/windows/configuration/start/layout?tabs=gpo%2Cintune-11&pivots=windows-10#deploy-the-start-layout-configuration
    foreach ($regAlias in @("HKLM", "HKCU")) {
        Set-RegistryValue -Path "${regAlias}:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "LockedStartLayout" -Value 1
        Set-RegistryValue -Path "${regAlias}:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "StartLayoutFile" -Value $layoutFilePath -Type String
    }
    Get-ChildItem -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\" `
        | Where-Object { $_.Name -like "*start.tilegrid*windows.data.curatedtilecollection*" } `
        | Remove-Item -Force -Recurse

    # # There is other trick to apply changes without reboot. I wouldn't rely on this also because of nondeterministic await
    # Invoke-RestartShell
    # # Open the StartMenu. (Necessary to load the new layout)
    # Start-Sleep 2
    # Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.SendKeys]::SendWait('^{ESC}')

    # # To ensure StartMenu applied changes, "Locked" state should stay put until the trick or reboot.
    # # I'd just leave it be. Since we are doing empty StartMenu, don't bother with ability to pin back.
    # foreach ($regAlias in @("HKLM", "HKCU")) {
    #     $keyPath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows\Explorer"
    #     Set-RegistryValue -Path $keyPath -Name "LockedStartLayout" -Value 0
    # }
    # Invoke-RestartShell

    # Imports the specified layout of Start into a mounted Windows image.
    # Makes layout default for all new users
    Import-StartLayout -LayoutPath $layoutFilePath -MountPath "$env:SystemDrive\"
    Remove-Item -Verbose -Recurse "$(Split-Path -Parent $layoutFilePath)"

    Invoke-RestartShell
}

# https://www.tenforums.com/tutorials/104828-enable-disable-recently-added-apps-start-menu-windows-10-a.html
function Invoke-StartMenuRecenlyAddedDisable {
    Write-Host 'StartMenu: Disable "Recently Added"'
    Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
    -Name "HideRecentlyAddedApps" -Value 1 -Type DWord
}

function Invoke-StartMenuTweaksApply {
    Invoke-StartMenuRecenlyAddedDisable
    Invoke-StartMenuSuggestionsDisable
    Invoke-StartMenuTilesRemove
}
