$v = [Int64]1
$UserPreferencesMask = [ordered]@{
    ActiveWindowTracking       = ($v -shl  0)
    MenuAnimation              = ($v -shl  1)
    ComboBoxAnimation          = ($v -shl  2)
    ListBoxSmoothScrolling     = ($v -shl  3)
    GradientCaptions           = ($v -shl  4)
    KeybordCues                = ($v -shl  5)
    ActiveWindowTrackingZOrder = ($v -shl  6)
    HotTracking                = ($v -shl  7)
    # Reserved                 = ($v -shl  8)
    MenuFade                   = ($v -shl  9)
    SelectionFade              = ($v -shl 10)
    ToolTipAnimation           = ($v -shl 11)
    ToolTipFade                = ($v -shl 12)
    CursorShadow               = ($v -shl 13)
    Sonar                      = ($v -shl 14)
    ClickLock                  = ($v -shl 15)
    HideMousePointer           = ($v -shl 16)
    VisualStyle                = ($v -shl 17)
    DropShadow                 = ($v -shl 18)
    #                                     ...
    UIEffects                  = ($v -shl 31)
    DisableOverlappedContent   = ($v -shl 32)
    ControlAnimation           = ($v -shl 33)
    ClearType                  = ($v -shl 34)
    SpeechRecognition          = ($v -shl 35)
}

# There is more straightforward solution in terms how computers work
# (to edit specific byte of byte[], without converting back and forth),
# but imo this is more straightforward in terms how to program it, read code.
function Toggle-UserPreference {
    PARAM($userPreference, $action)

    $upm = Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" `
    -Name "UserPreferencesMask" | Select-Object -ExpandProperty "UserPreferencesMask"
    if ($action) {
        $upm = [BitConverter]::GetBytes([BitConverter]::ToInt64($upm, 0) -bor $userPreference)
    } else {
        $upm = [BitConverter]::GetBytes([BitConverter]::ToInt64($upm, 0) -band -bnot $userPreference)
    }

    Set-RegistryValue -Path "HKCU:\Control Panel\Desktop" `
    -Name "UserPreferencesMask" -Value $upm -Type Binary
}

function Enable-UserPreference {
    PARAM($p)
    Toggle-UserPreference $p 1
}
function Disable-UserPreference {
    PARAM($p)
    Toggle-UserPreference $p 0
}
