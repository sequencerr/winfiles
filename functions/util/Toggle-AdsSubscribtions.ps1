# You can see all subscriptions IDs by
# Get-ChildItem "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager\Subscriptions" | Select -ExpandProperty Name | Sort

function Disable-SubscribtionById {
    PARAM($Ids)

    if (!($Ids -is [Array])) { $Ids = @($Ids) }
    foreach ($Id in $ids) {
        Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" `
        -Name "SubscribedContent-${Id}Enabled" -Value 0 -Type DWord
    }
}

# Settings -> System -> Notifications & actions -> "Windows Welcome Experience in Windows 10"
# aka "Show me the Windows welcome experience after updates and occasionally when I sign in to highlight what's new and suggested"
function Invoke-WelcomeExperienceSuggestionsDisable {
    Write-Host 'Disable "Windows Welcome Experience in Windows 10" (What''s new)'
    Disable-SubscribtionById 310093
}
# Settings -> Personalization -> Lock Screen -> Spotlight "Get fun facts, tips, tricks, and more on your lock screen"
function Invoke-LockScreenSuggestionsDisable {
    Write-Host 'Disable "Get fun facts, tips, tricks" (on lock screen)'
    Disable-SubscribtionById 338387
}
# https://www.tenforums.com/tutorials/24117-turn-off-app-suggestions-start-windows-10-a.html
# Settings -> Personalization -> Start -> "Show suggestions occasionally in Start"
function Invoke-StartMenuSuggestionsDisable {
    Write-Host 'StartMenu: Disable "Show Suggestions"'
    Disable-SubscribtionById 338388
}
# Settings -> System -> Notifications & actions -> "Get tips, tricks, and suggestions as you use Windows"
# aka "Tricks, and Suggestions Notifications about Windows 10"
function Invoke-WindowsSuggestionsDisable {
    Write-Host 'Disable "Get fun facts, tips, tricks" (notifications in OS)'
    Disable-SubscribtionById 338389
}
# Settings -> Privacy -> Windows permissions -> General -> Change privacy options -> "Show suggested content in the Settings app"
function Invoke-SettingsAppSuggestionsDisable {
    Write-Host 'Disable "Show suggested content in the Settings app"'
    Disable-SubscribtionById 338393, 353694, 353696, 88000105
}
# Settings -> System -> Multitasking -> Timeline -> "Show suggestions occasionally in Timeline"
# aka Policy "Show suggestions in your timeline"
function Invoke-TimelineSuggestionsDisable {
    Write-Host 'Disable "Show suggestions occasionally in Timeline"'
    Disable-SubscribtionById 353698
}
