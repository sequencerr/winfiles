function Invoke-PersonalizationTweaksApply {
    # https://www.tenforums.com/tutorials/5556-turn-off-transparency-effects-windows-10-a.html
    # Settings app -> Personaliztion -> Colors -> ...
    Write-Host 'Enable OS Dark Theme'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    -Name "AppsUseLightTheme"    -Value 0 -Type DWord
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    -Name "SystemUsesLightTheme" -Value 0 -Type DWord

    Write-Host 'Disable "Transparency Effects"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" `
    -Name "EnableTransparency" -Value 0 -Type DWord

    Write-Host 'Disable "Show desktop icons"'
    Set-RegistryValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "HideIcons" -Value 1 -Type DWord
    Invoke-RestartShell

    # https://www.tenforums.com/tutorials/90172-enable-disable-changing-lock-screen-background-windows-10-a.html
    # https://www.elevenforum.com/t/enable-or-disable-desktop-background-in-windows-11.12556/
    # Control Panel -> All Control Panel Items -> Ease of Access Center -> Make the computer easier to see -> Make things on the screen easier to see -> "Remove background images (where available)"
    Write-Host 'Enable  "Remove background images (where available)"'
    Enable-UserPreference $UserPreferencesMask.DisableOverlappedContent

    # https://www.elevenforum.com/t/enable-or-disable-show-lock-screen-background-on-sign-in-screen-in-windows-11.927/
    # Settings app -> Personaliztion -> Lock screen -> ...
    Write-Host 'Disable "Show lock screen background picture on the sign-in screen"'
    Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "DisableLogonBackgroundImage" -Value 1 -Type DWord

    # https://answers.microsoft.com/en-us/windows/forum/all/how-to-disable-pre-lock-screen-image-on-windows-10/bd18474b-bb5f-4606-a788-71811a32b728?page=1
    # Local Group Policy Editor Windows -> Computer Configuration \ Administrative Templates \ Control Panel \ Personalization -> "Do not display the lock screen".
    Write-Host 'Enable  "Do not display the lock screen"'
    Set-RegistryValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization" `
    -Name "NoLockScreen" -Value 1 -Type DWord

    Invoke-LockScreenSuggestionsDisable
    Invoke-WindowsSuggestionsDisable
    Invoke-WelcomeExperienceSuggestionsDisable
}
