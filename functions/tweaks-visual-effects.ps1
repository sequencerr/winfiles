# https://superuser.com/a/1419689
# https://www.elevenforum.com/t/enable-or-disable-font-smoothing-in-windows-11.8476
# SystemPropertiesPerformance.exe

function Invoke-VisualEffectsTweaksApply {
    Write-Host 'Must set appearance options to "Custom"'
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
    -Name "VisualFXSetting" -Value 3 -Type DWord

    Write-Host 'Disable "Animate controls and elements inside windows"'
    Disable-UserPreference $UserPreferencesMask.ControlAnimation

    Write-Host 'Disable "Animate windows when minimizing and maximizing"'
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" `
    -Name "MinAnimate" -Value "0" -Type String

    Write-Host 'Disable "Animations in the taskbar"'
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "TaskbarAnimations" -Value 0 -Type DWord

    Write-Host 'Disable "Enable Peek"'
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" `
    -Name "EnableAeroPeek" -Value 0 -Type DWord

    Write-Host 'Disable "Fade or slide menus into view"'
    Disable-UserPreference $UserPreferencesMask.MenuAnimation

    Write-Host 'Disable "Fade or slide ToolTips into view"'
    Disable-UserPreference $UserPreferencesMask.ToolTipAnimation

    Write-Host 'Disable "Fade out menu items after clicking"'
    Disable-UserPreference $UserPreferencesMask.SelectionFade

    Write-Host 'Disable "Save taskbar thumbnail previews"'
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" `
    -Name "AlwaysHibernateThumbnails" -Value 0 -Type DWord

    Write-Host 'Disable "Show shadows under mouse pointer"'
    Disable-UserPreference $UserPreferencesMask.CursorShadow

    Write-Host 'Disable "Show shadows under windows"'
    Disable-UserPreference $UserPreferencesMask.DropShadow

    Write-Host 'Enable  "Show thumbnails instead of icons"'
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "IconsOnly" -Value 0 -Type DWord

    Write-Host 'Disable "Show translucent selection rectangle"'
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ListviewAlphaSelect" -Value 0 -Type DWord

    Write-Host 'Disable "Show window contents while dragging"'
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" `
    -Name "DragFullWindows" -Value "0" -Type String

    Write-Host 'Disable "Slide open combo boxes"'
    Disable-UserPreference $UserPreferencesMask.ComboBoxAnimation

    Write-Host 'Enable  "Smooth edges of screen fonts"'
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" `
    -Name "FontSmoothing" -Value "2" -Type String

    Write-Host 'Disable "Smooth-scroll list boxes"'
    Disable-UserPreference $UserPreferencesMask.ListBoxSmoothScrolling

    Write-Host 'Disable "Use drop shadows for icon labels on the desktop"'
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ListviewShadow" -Value 0 -Type DWord

    Write-Host 'Most of "UserPreferencesMask" may not be displayed as changed until system restart'
}
