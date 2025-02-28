# SystemPropertiesPerformance.exe

# Animate controls and elements inside windows
# Animate windows when minimizing and maximizing
# Animations in the taskbar
# Enable Peek
# Fade or slide menus into view
# Fade or slide ToolTips into view
# Fade out menu items after clicking
# Save taskbar thumbnail previews
# Show shadows under mouse pointer
# Show shadows under windows
# Show thumbnails instead of icons
# Show translucent selection rectangle
# Show window contents while dragging
# Slide open combo boxes
# Smooth edges of screen fonts
# Smooth-scroll list boxes
# Use drop shadows for icon labels on the desktop

function Invoke-PerfomanceOptionsDisable {
    Write-Host 'Must set appearance options to "Custom"'
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" `
    -Name "VisualFXSetting" -Value 3 -Type DWord

    # This disables the following 8 settings:
    Write-Host "Animate controls and elements inside windows"
    Write-Host "Fade or slide menus into view"
    Write-Host "Fade or slide ToolTips into view"
    Write-Host "Fade out menu items after clicking"
    Write-Host "Show shadows under mouse pointer"
    Write-Host "Show shadows under windows"
    Write-Host "Slide open combo boxes"
    Write-Host "Smooth-scroll list boxes"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" `
    -Name "UserPreferencesMask" -Value (0x90, 0x12, 0x03, 0x80, 0x10, 0x00, 0x00, 0x00) -Type Binary
    Write-Host "Animate windows when minimizing and maximizing"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" `
    -Name "MinAnimate" -Value "0"
    Write-Host "Animations in the taskbar"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "TaskbarAnimations" -Value 0 -Type DWord
    Write-Host "Enable Peek"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" `
    -Name "EnableAeroPeek" -Value 0 -Type DWord
    Write-Host "Save taskbar thumbnail previews"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\DWM" `
    -Name "AlwaysHibernateThumbnails" -Value 0 -Type DWord
    Write-Host "Show thumbnails instead of icons"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "IconsOnly" -Value 0 -Type DWord
    Write-Host "Show translucent selection rectangle"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ListviewAlphaSelect" -Value 0 -Type DWord
    Write-Host "Show window contents while dragging"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" `
    -Name "DragFullWindows" -Value "0"
    Write-Host "Smooth edges of screen fonts"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" `
    -Name "FontSmoothing" -Value "2"
    Write-Host "Use drop shadows for icon labels on the desktop"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ListviewShadow" -Value 0 -Type DWord
    Write-Host 'Most of "UserPreferencesMask" may not be displayed as changed until system restart'
}
