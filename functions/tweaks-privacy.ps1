#region General =================================

function Invoke-AppsExposeAdsIdDisable {
    # "Let apps use advertising ID to make ads more interesting
    # to you based on your app activity (Turning this off will
    # reset your ID.)"
    # aka
    Write-Host 'Disable "Let apps use your advertising ID"'

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
    -Name "Enabled" -Value 0 -Type DWord
    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
    -Name "Id" -ErrorAction SilentlyContinue
}

function Invoke-WebExposeLanguageListDisable {
    # "Let websites provide locally relevant content by accessing
    # my language list"
    # aka
    Write-Host 'Disable "Let websites access my language list"'

    Set-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" `
    -Name "HttpAcceptLanguageOptOut" -Value 1 -Type DWord
    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Internet Explorer\International" `
    -Name "AcceptLanguage" -ErrorAction SilentlyContinue
}
function Invoke-WebExposeLanguageListEnable {
    Remove-ItemProperty -Path "HKCU:\Control Panel\International\User Profile" `
    -Name "HttpAcceptLanguageOptOut" -ErrorAction SilentlyContinue

    # This value should be stored/generated based on OS settings.
    # This is basically "Accept-Language" request header
    # Resettings its value skipped by some articles.
    # "HKCU:\SOFTWARE\Microsoft\Internet Explorer\International\AcceptLanguage"
    # Set: "Type: REG_SZ, Length: 30, Data: en-US,en;q=0.5"
}

function Invoke-TrackAppLaunchesDisable {
    # "Let Windows track app launches to improve Start and
    # search results"
    # aka
    Write-Host 'Disable "Let Windows track app launches"'

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "Start_TrackProgs" -Value 0 -Type DWord
}

function Invoke-SettingsAppSuggestionsDisable {
    # Settings -> Privacy -> Windows permissions -> General -> Change privacy options -> ...
    Write-Host 'Disable "Show suggested content in the Settings app"'

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-338393Enabled" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-353694Enabled" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-353696Enabled" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-88000105Enabled" -Value 0 -Type DWord
}

function Invoke-SettingsAppNotificationsDisable {
    # "Show me notifications in the Settings app. When off,
    # required notifications are still shown."
    # aka
    Write-Host 'Disable "Show notifications in the Settings app"'

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SystemSettings\AccountNotifications" `
    -Name "EnableAccountNotifications" -Value 0 -Type DWord
}
#endregion =================================

#region Speech =================================

# https://www.tenforums.com/tutorials/120628-enable-disable-speech-recognition-voice-activation-windows-10-a.html
# https://nextup.com/forum/viewtopic.php?t=6076
# Windows 10 (64 bit)
# C:\Windows\SysWOW64\Speech\SpeechUX\sapi.cpl
# Windows 10 (32 bit)
# C:\Windows\System32\Speech\SpeechUX\sapi.cpl
# or
# Control Panel -> All Control Panel Items -> Speech Recognition -> Advanced speech options -> User Settings
function Invoke-SpeechRecognitionPrivacyApply {
    Write-Host 'Disable "Run Speech Recognition at startup"'
    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" `
    -Name "Speech Recognition" -ErrorAction SilentlyContinue

    Write-Host 'Disable "Review documents and mail to improve accuracy"'
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Speech\Preferences" `
    -Name "EnableDocumentHarvesting" -Value 0 -Type DWord

    # Write-Host 'Disable "Enable voice activation"'
    # Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Speech\Preferences" `
    # -Name "ModeForOff" -Value 1 -Type DWord
    # # 2 = Enable
}

# https://www.tenforums.com/tutorials/101902-turn-off-online-speech-recognition-windows-10-a.html
# The Settings app already describes it,
# but putting it in a simple terms,
# by disagreeing allowing speech data be processed(transcoded remotely), and also used by them for future trainings
# on Microsoft servers(Windows cloud-based services), it effectively removes ability to use some features locally.
# (like Cortana/dictation which were mentioned there)
function Invoke-SpeechRecognitionOnlineDisable {
    Write-Host 'Disable "Online speech recognition"'

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" `
    -Name "HasAccepted" -Value 0 -Type DWord
}
#endregion =================================

#region Inking =================================

# https://www.tenforums.com/tutorials/118127-how-turn-off-inking-typing-personalization-windows-10-a.html
# https://www.elevenforum.com/t/enable-or-disable-custom-inking-and-typing-dictionary-in-windows-11.5564/
function Invoke-PersonalTypingDictionaryDisable {
    Write-Host 'Disable "Personal typing & inking dictionary" (it will be erased)'

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Personalization\Settings" `
    -Name "AcceptedPrivacyPolicy" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\SettingSync\Groups\Language" `
    -Name "Enabled" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" `
    -Name "RestrictImplicitTextCollection" -Value 1 -Type DWord
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization" `
    -Name "RestrictImplicitInkCollection" -Value 1 -Type DWord
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\InputPersonalization\TrainedDataStore" `
    -Name "HarvestContacts" -Value 0 -Type DWord
}
#endregion =================================

#region Diagnostics =================================

$TelemetryLevel = @{
    Security = 0 # (for Enterprise only)
    Required = 1 # (basic)
    Enchanced = 2
    Optional = 3 # (full)
}

# https://www.tenforums.com/tutorials/7032-change-diagnostic-data-settings-windows-10-a.html
function Invoke-TelemetrySwitchSetRequiredOnly {
    Write-Host 'Disable "Diagnostic data" (Setting only "Required diagnostic data")'

    # Change Settings app switch value.
    # > Setting a value of 0 for "Security" applies to enterprise, EDU, IoT and server devices only.
    # > for other devices is equivalent to choosing a value of 1.
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Diagnostics\DiagTrack" `
    -Name "ShowedToastAtLevel" -Value $TelemetryLevel.Security -Type DWord

    # You can't edit switch value to "Optional" by default (it's grayed out),
    # unless policy(Group Policy one, not this Settings app registry key with "Policies" in name)
    # is set to "Optional"
    # but we don't need it, because "Optional" is actually full (all telemetry levels + optional), not just optional.
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" `
    -Name "AllowTelemetry" -Value $TelemetryLevel.Security -Type DWord
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" `
    -Name "MaxTelemetryAllowed" -Value $TelemetryLevel.Security -Type DWord

    # You can't fully disable telemetry in Windows 10 Home or Pro editions by changing switch value.
    # Trying to disable the services below. It could cause unexpected issues.
    Write-Host "Stoppping Diagnostics services..."
    Write-Host 'Disable "Diagnostics Tracking Service"' # aka "Connected User Experiences and Telemetry"
    Get-Service -Name "DiagTrack" | Stop-Service -Force
    Set-Service -Name "DiagTrack" -StartupType Disabled -Status Stopped
}

# https://www.elevenforum.com/t/enable-or-disable-improve-inking-and-typing-in-windows-11.7575/
function Invoke-TelemetryTypingDisable {
    Write-Host 'Disable "Improve inking and typing" (Don''t "Send optional inking and typing diagnostic data")'

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Input\TIPC" `
    -Name "Enabled" -Value 0 -Type DWord
}

# https://www.tenforums.com/tutorials/76426-turn-off-tailored-experiences-diagnostic-data-windows-10-a.html
function Invoke-TelemetryTailoredDisable {
    Write-Host 'Disable "Tailored expreriences" (Don''t "Offer personalized ads based on diagnostic data")'

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" `
    -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type DWord

    # This will override previous setting.
    # (delete) = Enable
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
    -Name "DisableTailoredExperiencesWithDiagnosticData" -Value 1 -Type DWord
}

# https://www.tenforums.com/tutorials/2441-how-change-feedback-frequency-windows-10-a.html
function Invoke-FeedbackNotificationDisable {
    Write-Host 'Disable "Feedback frequency" (Disallow Windows send notifications asking for my feedback)'

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" `
    -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord
    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Siuf\Rules" `
    -Name "PeriodInNanoSeconds" -ErrorAction SilentlyContinue

    # Like in other scripts, there are policy alternatives.
    # but I focused on just on HCKU/HKLM (becacause they were enough and leaving ability to change setting).
    # idk why here both, but it's kind of different a bit.
    # ...we have "Never" period, and a completely disabled feature.
    # (delete) = Enable
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
    -Name "DoNotShowFeedbackNotifications" -Value 1 -Type DWord
}
#endregion =================================

#region Timeline =================================

# https://www.elevenforum.com/t/enable-or-disable-store-activity-history-on-device-in-windows-11.7812/
function Invoke-TimelinePrivacyPublishUserActivitiesDisable {
    # Local Group Policy Editor -> Computer Configuration -> Administrative Templates -> System -> OS Policies​
    # aka Policy "Allow publishing of User Activities"
    Write-Host 'Disable "Store my activity history on this device"'

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "PublishUserActivities" -Value 0 -Type DWord
}

# https://www.elevenforum.com/t/enable-or-disable-send-activity-history-to-microsoft-in-windows-11.7810/
# Checkbox is not always visible. I guess you need not local Windows account.
function Invoke-TimelinePrivacyUploadUserActivitiesDisable {
    # Local Group Policy Editor -> Computer Configuration -> Administrative Templates -> System -> OS Policies​
    # aka Policy "Allow upload of User Activities"
    Write-Host 'Disable "Send my activity history to Microsoft"'

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "UploadUserActivities" -Value 0 -Type DWord
}

# https://www.tenforums.com/tutorials/101852-enable-disable-timeline-windows-10-a.html
function Invoke-TimelineDisable {
    Write-Host 'Disable "Timeline" feature altogether'

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" `
    -Name "EnableActivityFeed" -Value 0 -Type DWord
}

function Invoke-TimelineAppSuggestionsDisable {
    # Settings -> System -> Multitasking -> Timeline -> "Show suggestions occasionally in Timeline"
    # aka Policy "Show suggestions in your timeline"
    Write-Host 'Disable "Show suggestions occasionally in Timeline"'

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
    -Name "SubscribedContent-353698Enabled" -Value 0 -Type DWord
}
#endregion =================================

function Invoke-PrivacyWindowsPermissionsDisable {
    Write-Host "Settings -> Privacy -> Windows permissions -> ..."

    Write-Host "... -> General -> Change privacy options -> ..."
    Invoke-AppsExposeAdsIdDisable
    Invoke-WebExposeLanguageListDisable
    Invoke-TrackAppLaunchesDisable
    Invoke-SettingsAppSuggestionsDisable
    Invoke-SettingsAppNotificationsDisable
    Write-Host "Done."

    Write-Host "... -> Speech -> ..."
    Invoke-SpeechRecognitionPrivacyApply
    Invoke-SpeechRecognitionOnlineDisable
    Write-Host "Done."

    Write-Host "... -> Inking & typing personalization -> ..."
    Invoke-PersonalTypingDictionaryDisable
    Write-Host "Done."

    Write-Host "... -> Diagnostics & feedback -> ..."
    Invoke-TelemetrySwitchSetRequiredOnly
    Invoke-TelemetryTypingDisable
    Invoke-TelemetryTailoredDisable
    Invoke-FeedbackNotificationDisable
    Write-Host "Done."

    Write-Host "... -> Activity history -> ..."
    # "Timeline" is part of the "Task View"
    Invoke-TimelineAppSuggestionsDisable
    Invoke-TimelinePrivacyPublishUserActivitiesDisable
    Invoke-TimelinePrivacyUploadUserActivitiesDisable
    Invoke-TimelineDisable
    Write-Host "Done."

    Write-Host "Done."
}

function Invoke-PrivacyAppPermissionsDisable {
    Write-Host "Settings -> Privacy -> App Permissions -> ..."

    Write-Host "Disabling `"Voice activation`""
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" `
    -Name "AgentActivationEnabled" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Speech_OneCore\Settings\VoiceActivation\UserPreferenceForAllApps" `
    -Name "AgentActivationOnLockScreenEnabled" -Value 0 -Type DWord

    Write-Host "Disabling `"Background apps`""
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" `
    -Name "BackgroundAppGlobalToggle" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" `
    -Name "GlobalUserDisabled" -Value 1 -Type DWord

    # Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore"
    $capabilityAccessKeys = [ordered]@{
        "Location" = "location"
        "Camera" = "webcam"
        "Microphone" = "microphone"
        # "Voice activation" - other registry key
        "Notifications" = "userNotificationListener"
        "Account info" = "userAccountInformation"
        "Contacts" = "contacts"
        "Calendar" = "appointments"
        "Phone calls" = "phoneCall"
        "Call history" = "phoneCallHistory"
        "Email" = "email"
        "Tasks" = "userDataTasks"
        "Messaging" = "chat"
        "Radios" = "radios"
        "Other devices" = "bluetoothSync"
        # "Background apps" - other registry key
        "App diagnostics" = "appDiagnostics"
        # "Automatic file downloads" - is missing switch
        "Documents" = "documentsLibrary"
        "Pictures" = "picturesLibrary"
        "Videos" = "videosLibrary"
        "File system" = "broadFileSystemAccess"

        # Unlisted:
        #   "activity"
        #   "bluetooth"
        #   "cellularData"
        #   "gazeInput"
        #   "humanInterfaceDevice"
        #   "sensors.custom"
        #   "serialCommunication"
        #   "usb"
        #   "wifiData"
        #   "wiFiDirect"
    }
    foreach ($entry in $capabilityAccessKeys.GetEnumerator()) {
        $name = $entry.Key
        $cap = $entry.Value
        Write-Host "Disabling `"$name`""

        # Allow/Deny
        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\$cap" `
        -Name "Value" -Value "Deny" -Type String
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\$cap" `
        -Name "Value" -Value "Deny" -Type String

        if (!(Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\$cap\NonPackaged")) { continue }
        Write-Host "Disabling `"$name`" for Desktop apps"
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\$cap\NonPackaged" `
        -Name "Value" -Value "Deny" -Type String
    }
    Write-Host "Done."
}

function Invoke-PrivacyHarden {
    Invoke-PrivacyWindowsPermissionsDisable
    Invoke-PrivacyAppPermissionsDisable
}
