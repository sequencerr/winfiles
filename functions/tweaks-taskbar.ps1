# https://learn.microsoft.com/en-us/windows/configuration/taskbar/policy-settings?tabs=taskbar&pivots=windows-10
# https://learn.microsoft.com/en-us/windows-hardware/customize/desktop/customize-the-taskbar
# https://www.tenforums.com/tutorials/5313-hide-show-notification-area-icons-taskbar-windows-10-a.html
# https://www.tenforums.com/tutorials/105189-enable-disable-taskbar-settings-windows-10-a.html
# https://mymce.wordpress.com/2022/10/04/how-to-change-taskbar-position-via-registry-in-windows-10-11/

function Invoke-TaskBarSearchTweak {
    # Write-Host 'TaskBar: Disabling Search: "Open on hover"'
    # Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds\DSB" `
    # -Name "OpenOnHover" -Value 0 -Type DWord
    # Write-Host 'TaskBar: Disabling Search: "Show search highlights"'
    # Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds\DSB" `
    # -Name "ShowDynamicContent" -Value 0 -Type DWord
    # # Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" `
    # # -Name "IsDynamicSearchBoxEnabled" -Value 0 -Type DWord
    Write-Host "TaskBar: Hiding Search"
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" `
    -Name "SearchboxTaskbarMode" -Value 0 -Type DWord

    # https://www.howtogeek.com/224159/how-to-disable-bing-in-the-windows-10-start-menu/
    # https://www.supportyourtech.com/articles/how-to-remove-bing-from-windows-10-a-step-by-step-guide/
    Write-Host "TaskBar: Search: Removing Bing"
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" `
    -Name "BingSearchEnabled" -Value 0 -Type DWord
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
    -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord

    # todo:
    # https://answers.microsoft.com/en-us/windows/forum/all/how-to-remove-suggested-in-search-bar/698c41d5-0928-44a8-9da9-4c9ee2639565
    # https://answers.microsoft.com/en-us/windows/forum/all/how-to-remove-change-top-apps-in-windows-11/98d6dd12-ae83-4080-8f2e-f59427ad84d7
    # https://github.com/krlvm/BeautySearch
}

function Invoke-TaskBarIconsHide {
    Write-Host "TaskBar: Hiding TaskView"
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowTaskViewButton" -Value 0 -Type DWord

    Write-Host "TaskBar: Hiding System Icon: Meet Now"
    Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "HideSCAMeetNow" -Value 1 -Type DWord

    Write-Host "TaskBar: Hiding System Icon: Action Center"
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
    -Name "DisableNotificationCenter" -Value 1 -Type DWord
}

function Invoke-TaskBarAppearance {
    $prefsBinary = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" -Name "Settings" -ErrorAction SilentlyContinue).Settings

    Write-Host 'TaskBar: Set    "Taskbar location on screen" -> "Left"'
    # 00 Left
    # 01 Top
    # 02 Right
    # 03 Bottom
    $prefsBinary[12] = 0x00

    Write-Host 'TaskBar: Enable "Automatically hide the taskbar in desktop mode"'
    $prefsBinary[8] = 0x03 # 2 - disable

    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3" `
    -Name "Settings" -Value $prefsBinary -Type Binary
}

function Invoke-TaskBarTweaksApply {
    Write-Host "TaskBar: Disabling Immersive context menu"
    Set-RegistryValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "NoTrayContextMenu" -Value 1 -Type DWord

    # A.K.A "Always show all icons and notifications on the taskbar" in "explorer shell:::{05d7b0f4-2121-4eff-bf6b-ed3f69b894d9}"
    Write-Host 'TaskBar: Enabling "Always show all icons in the notification area"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" `
    -Name "EnableAutoTray" -Value 0 -Type DWord

    Invoke-TaskBarIconsHide
    Invoke-TaskBarSearchTweak
    Invoke-TaskBarAppearance

    Invoke-RestartShell
}
