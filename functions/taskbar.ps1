# https://learn.microsoft.com/en-us/windows/configuration/taskbar/policy-settings?tabs=taskbar&pivots=windows-10

function Invoke-TaskBarSearchTweak {
    # Write-Host 'TaskBar: Disabling Search: "Open on hover"'
    # Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds\DSB" `
    # -Name "OpenOnHover" -Value 0 -Type DWord
    # Write-Host 'TaskBar: Disabling Search: "Show search highlights"'
    # Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Feeds\DSB" `
    # -Name "ShowDynamicContent" -Value 0 -Type DWord
    # # Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SearchSettings" `
    # # -Name "IsDynamicSearchBoxEnabled" -Value 0 -Type DWord
    Write-Host "TaskBar: Hiding Search"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" `
    -Name "SearchboxTaskbarMode" -Value 0 -Type DWord

    # https://www.howtogeek.com/224159/how-to-disable-bing-in-the-windows-10-start-menu/
    # https://www.supportyourtech.com/articles/how-to-remove-bing-from-windows-10-a-step-by-step-guide/
    Write-Host "TaskBar: Search: Removing Bing"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" `
    -Name "BingSearchEnabled" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
    -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord

    # todo:
    # https://answers.microsoft.com/en-us/windows/forum/all/how-to-remove-suggested-in-search-bar/698c41d5-0928-44a8-9da9-4c9ee2639565
    # https://answers.microsoft.com/en-us/windows/forum/all/how-to-remove-change-top-apps-in-windows-11/98d6dd12-ae83-4080-8f2e-f59427ad84d7
    # https://github.com/krlvm/BeautySearch
}

function Invoke-TaskBarTweaksApply {
    Write-Host "TaskBar: Hiding TaskView"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowTaskViewButton" -Value 0 -Type DWord
    Write-Host "TaskBar: Hiding System Icon: Meet Now"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "HideSCAMeetNow" -Value 1 -Type DWord
    Write-Host "TaskBar: Hiding System Icon: Action Center"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer" `
    -Name "DisableNotificationCenter" -Value 1 -Type DWord

    Write-Host "TaskBar: Disabling Immersive context menu"
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -Name "NoTrayContextMenu" -Value 1 -Type DWord

    Invoke-TaskBarSearchTweak

    Invoke-RestartShell
}
