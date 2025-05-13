# https://www.elevenforum.com/t/change-folder-to-open-file-explorer-to-by-default-in-windows-11.675/
# https://learn.microsoft.com/en-us/answers/questions/1502040/how-to-correctly-find-the-downloads-folder-in-powe
function Invoke-ExplorerStartDirectoryApply {
    # Set not to "Quick Access", but to "This PC" for fallback
    Set-RegistryValue "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "LaunchTo" -Value 1 -Type DWord

    $downloadsPath = (New-Object -ComObject Shell.Application).Namespace('shell:Downloads').Self.Path
    Write-Host "Setting File Explorer to Open to Custom Location by Default..."
    Write-Host "Using directory: `"$downloadsPath`""

    $regPath = "HKCU:\SOFTWARE\Classes\CLSID\{52205fd8-5dfb-447d-801a-d0b52f2e83e1}\shell\OpenNewWindow\command"
    Set-RegistryValue -Path $regPath `
    -Name "(Default)" -Value "Explorer `"$downloadsPath`"" -Type String
    Set-RegistryValue -Path $regPath `
    -Name "DelegateExecute" -Value "" -Type String
}

# https://www.winhelponline.com/blog/show-recently-used-files-in-quick-access-unchecked-automatically/
# https://www.tenforums.com/tutorials/2712-add-remove-frequent-folders-quick-access-windows-10-a.html
function Invoke-ExplorerPrivacyApply {
    Write-Host 'Removing from "Quick access" the "Frequent Places Folder" special shell folder...'
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders\{3936E9E4-D92C-4EEE-A85A-BC16D5EA0819}" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders\{3936E9E4-D92C-4EEE-A85A-BC16D5EA0819}" -Recurse -Force -ErrorAction SilentlyContinue

    Write-Host 'Removing from "Quick access" the "Recent Files Folder" special shell folder...'
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders\{3134ef9c-6b18-4996-ad04-ed5912e00eb5}" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\HomeFolderDesktop\NameSpace\DelegateFolders\{3134ef9c-6b18-4996-ad04-ed5912e00eb5}" -Recurse -Force -ErrorAction SilentlyContinue

    # By all means we already hid all those privacy features by deleting shell handlers,
    # but also we'll apply config settings to be sure and for fallback

    Write-Host "Disable: Show recently opened items in Start, Jump Lists, and File Explorer"
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "Start_TrackDocs" -Value 0 -Type DWord

    Write-Host "Disable: Show recently used files in Quick Access"
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" `
    -Name "ShowRecent" -Value 0 -Type DWord

    Write-Host "Disable: Show frequently used folder in Quick access"
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" `
    -Name "ShowFrequent" -Value 0 -Type DWord
}

# https://www.howtogeek.com/222057/how-to-remove-the-folders-from-this-pc-on-windows-10/
# https://www.tenforums.com/tutorials/6015-add-remove-folders-pc-windows-10-a.html
function Invoke-ExplorerThisPCApply {
    Write-Host 'Removing from "This PC" the "3D Objects"...'
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{0DB7E03F-FC29-4DC6-9020-FF41B59E513A}" -Force -ErrorAction SilentlyContinue

    Write-Host "Removing from "This PC" the "Desktop"..."
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{B4BFCC3A-DB2C-424C-B029-7FE99A87C641}" -Force -ErrorAction SilentlyContinue

    Write-Host "Removing from "This PC" the "Documents"..."
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A8CDFF1C-4878-43be-B5FD-F8091C1C60D0}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{d3162b92-9365-467a-956b-92703aca08af}" -Force -ErrorAction SilentlyContinue

    Write-Host "Removing from "This PC" the "Downloads"..."
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{374DE290-123F-4565-9164-39C4925E467B}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{088e3905-0323-4b02-9826-5d99428e115f}" -Force -ErrorAction SilentlyContinue

    Write-Host "Removing from "This PC" the "Music"..."
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{1CF1260C-4DD0-4ebb-811F-33C572699FDE}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3dfdf296-dbec-4fb4-81d1-6a3438bcf4de}" -Force -ErrorAction SilentlyContinue

    Write-Host "Removing from "This PC" the "Pictures"..."
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{3ADD1653-EB32-4cb0-BBD7-DFA0ABB5ACCA}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{24ad3ad4-a569-4530-98e1-ab02f9417aa8}" -Force -ErrorAction SilentlyContinue

    Write-Host "Removing from "This PC" the "Videos"..."
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{A0953C92-50DC-43bf-BE83-3742FED03C9C}" -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Explorer\MyComputer\NameSpace\{f86fa3ab-70d2-4fc7-9c99-fcbf05467f3a}" -Force -ErrorAction SilentlyContinue
}

# https://msfn.org/board/topic/149556-registry-keys-that-control-explorer-folder-view-options/page/2/
# https://stackoverflow.com/questions/4491999/configure-windows-explorer-folder-options-through-powershell
# https://winaero.com/how-to-change-file-explorer-options-in-the-registry/
# The "Explorer" -> "View" tab -> "Options" -> "Folder Options" -> "View" -> "Advanced Settings" -> "Files and Folders"
# or "rundll32 shell32.dll,Options_RunDLL 7"
function Invoke-ExplorerAdvancedSettingsApply {
    Write-Host 'Disable: "Always show icons, never thumbnails"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "IconsOnly" -Value 0 -Type DWord

    Write-Host 'Disable: "Always show menus"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "AlwaysShowMenus" -Value 0 -Type DWord

    Write-Host 'Enable:  "Display file icon on thumbnails"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowTypeOverlay" -Value 1 -Type DWord

    Write-Host 'Enable:  "Display file size information in folder tips"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "FolderContentsInfoTip" -Value 1 -Type DWord

    Write-Host 'Enable:  "Display the full path in the title bar" (on tabs)'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\CabinetState" `
    -Name "FullPath" -Value 1 -Type DWord

    Write-Host 'Disable: "Hidden files and folders" -> "Dont show hidden files, folders, or drives"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "Hidden" -Value 1 -Type DWord

    Write-Host 'Disable: "Hide empty drives"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "HideDrivesWithNoMedia" -Value 0 -Type DWord

    Write-Host 'Disable: "Hide extensions for known file types"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "HideFileExt" -Value 0 -Type DWord

    Write-Host 'Enable:  "Hide folder merge conflicts"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "HideMergeConflicts" -Value 1 -Type DWord

    Write-Host 'Enable:  "Hide protected operating system files (Recommended)"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowSuperHidden" -Value 1 -Type DWord

    Write-Host 'Disable: "Launch folder windows in a separate process"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "SeparateProcess" -Value 0 -Type DWord

    Write-Host 'Disable: "Restore previous folder windows at logon"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "PersistBrowsers" -Value 0 -Type DWord

    Write-Host 'Enable:  "Show drive letters" (first)'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" `
    -Name "ShowDriveLettersFirst" -Value 1 -Type DWord

    Write-Host 'Enable:  "Show encrypted or compressed NTFS files in color"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowEncryptCompressedColor" -Value 1 -Type DWord

    Write-Host 'Enable:  "Show pop-up description for folder and desktop items"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowInfoTip" -Value 1 -Type DWord

    Write-Host 'Enable:  "Show preview handlers in preview pane"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowPreviewHandlers" -Value 1 -Type DWord

    Write-Host 'Enable:  "Show status bar"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowStatusBar" -Value 1 -Type DWord

    Write-Host 'Disable: "Show sync provider notifications"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "ShowSyncProviderNotifications" -Value 0 -Type DWord

    Write-Host 'Disable: "Use check boxes to select items"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "AutoCheckSelect" -Value 0 -Type DWord

    Write-Host 'Disable: "Use Sharing Wizard (Recommended)"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "SharingWizardOn" -Value 0 -Type DWord

    Write-Host 'Enable:  "When typing into list view" -> "Select the typed item in the view"'
    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" `
    -Name "TypeAhead" -Value 0
}

# https://answers.microsoft.com/en-us/windows/forum/all/windows-7-windows-explorer-lock-the-toolbars/a9e16957-d415-4208-ad06-f6752b4a999d
# https://thegeekpage.com/remove-white-line-below-address-bar/
# Fix white ribbon/line appearing in dark mode under the search bar
function Invoke-ExplorerRibbonDisable {
    Write-Host 'Disable: "Lock the toolbars" (Remove white stripe)'
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Internet Explorer\Toolbar" `
    -Name "Locked" -Value 1 -Type DWord
}

# https://youtu.be/KjHfCDPfLdI?t=216 - Originally spotted in this video, author missunderstood the "Content Indexing" flags and "Indexing" as it is.
# https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Fwww.askdavetaylor.com%2F4-blog-pics%2Fwindows-c-drive-properties.jpg
# /\ but I believe it was called "Allow Indexing Service to index this disk for fast file searching" in that place before. (God knows what it actually meant)
# https://www.webnots.com/how-to-customize-windows-search/
# So this option doesn't really affect performance/storage, until you configure indexer generally.
# But it's nice to have this script to uncheck everything in fast and verbose (default progress doesn't really give perspective on how much time left) way.
# https://www.tenforums.com/tutorials/93736-allow-file-contents-properties-indexed-drive-windows.html
# https://devblogs.microsoft.com/scripting/use-a-powershell-cmdlet-to-work-with-file-attributes/
# https://web.archive.org/web/20190501162727/https://devblogs.microsoft.com/scripting/use-powershell-to-toggle-the-archive-bit-on-files/
# https://learn.microsoft.com/en-us/dotnet/api/system.io.fileattributes?view=net-9.0
# https://learn.microsoft.com/en-us/dotnet/api/system.io.file.setattributes?view=net-9.0
# Explorer -> This PC -> "System Drive" aka "Disc C" Properties -> "General" Tab -> "Allow files on this drive to have contents indexed in addition to file properties" -> "Apply changes to drive C:\, subfolders and files"
function Invoke-ExplorerContentIndexedDisable {
    $drive = "$env:SystemDrive\"
    Write-Host "Disable: `"Allow files on '$drive' drive to have contents indexed`" (Apply attributes flag to very each file)"

    # https://stackoverflow.com/a/77846183/10941348
    [System.Environment]::SetEnvironmentVariable('Count', 0, 'User')
    $job = Start-Job -ScriptBlock {
        Get-ChildItem -Path $Using:drive -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $i = 0 }{
            if (++$i % 1000 -ne 0) { return }
            [System.Environment]::SetEnvironmentVariable('Count', $i, 'User')
        }
        [System.Environment]::SetEnvironmentVariable('Count', $i, 'User')
    }

    Get-ChildItem -Path $drive -Recurse -ErrorAction SilentlyContinue | ForEach-Object { $i = 0; $s = Get-Date }{
        if ($i++ % 1000 -eq 0) {
            $count = [Int][System.Environment]::GetEnvironmentVariable('Count', 'User')
            $percent = $leftTime = 0
            if ($count -gt $i) {
                $percent = $i / $count * 100
                $leftTime = ((Get-Date) - $s).TotalSeconds / $i * ($count - $i)
            }
            Write-Progress -Activity "Applying attribute..." -PercentComplete $percent -SecondsRemaining $leftTime `
                -Status "[$($i.ToString().PadLeft(6, ' '))/$("$(if($count){$count}else{"..."})".PadLeft(6, ' '))] $($_.FullName)"
        }

        try {
            [System.IO.File]::SetAttributes($_.FullName, $_.Attributes -bor [System.IO.FileAttributes]::NotContentIndexed)
        } catch [System.UnauthorizedAccessException] {
        } catch {
            Write-Error $_
        }
    }

    Stop-Job -Job $job
    Remove-Job -Job $job -Force
    [System.Environment]::SetEnvironmentVariable('Count', $null, 'User')
}

# https://youtu.be/ctMyvJsBSzI?t=1077
# Make Windows faster Explorer for big media(and not) directories
function Invoke-ExplorerDiscoveryDisable {
    Write-Host 'Disable: "Automatic Folder Discovery" feature'
    $regBase = "HKCU:\SOFTWARE\Classes\Local Settings\Software\Microsoft\Windows\Shell"
    Remove-Item -Path "$regBase\Bags" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item -Path "$regBase\BagMRU" -Recurse -Force -ErrorAction SilentlyContinue
    Set-RegistryValue -Path "$regBase\Bags\AllFolders\Shell" `
    -Name "FolderType" -Value "NotSpecified" -Type String
}

function Invoke-ExplorerTweaksApply {
    Invoke-ExplorerStartDirectoryApply
    Invoke-ExplorerThisPCApply
    Invoke-ExplorerPrivacyApply
    Invoke-ExplorerAdvancedSettingsApply
    Invoke-ExplorerRibbonDisable
    Invoke-ExplorerDiscoveryDisable
    Invoke-ExplorerContentIndexedDisable

    Invoke-RestartShell
}
