# https://superuser.com/questions/930195/force-windows-8-1-task-manager-to-always-show-more-details
# https://www.reddit.com/r/pcmasterrace/comments/3oavq0/something_about_task_manager_that_grinds_my_gears/

function Invoke-TaskManagerPreferencesReset {
    Stop-Process -Name "taskmgr" -ErrorAction SilentlyContinue
    Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager\Preferences" -Force -ErrorAction SilentlyContinue

    $process = Start-Process "taskmgr.exe" -PassThru -WindowStyle Minimized

    # Not sure if window is really what triggers "Status" column to appear,
    # but we need this delay, that way so this function won't bug out: jumping immediately to
    # get registry key value code block, and while window is barely opened,
    # it somehow gets the value(previous one?) (though we deleted the key)
    # and after all, immediately returns.
    $stage = 'Waiting for "taskmgr.exe" window handle to appear...'
    for ($i = 0; $True; ++$i) {
        $window = Get-Process -Id $process.Id -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 }
        if (!$window) {
            $time = "$(($i * 50 / 1000).ToString().PadRight(5, ' '))s"
            Write-Progress -Activity "Resetting TaskManager preferences..." `
                -PercentComplete 0 `
                -Status "$time $stage"

            Start-Sleep -Milliseconds 50
        } else {
            Write-Progress -Activity "Resetting TaskManager preferences..." `
                -PercentComplete 70 `
                -Status "Done. $stage"

            break
        }
    }

    $stage = 'Waiting for "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager" to create...'
    for ($i = 0; $True; ++$i) {
        $prefsBinary = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue).Preferences
        if (!$prefsBinary) {
            $time = "$(($i * 50 / 1000).ToString().PadRight(5, ' '))s"
            Write-Progress -Activity "Resetting TaskManager preferences..." `
                -PercentComplete 70 `
                -Status "$time $stage"

            Start-Sleep -Milliseconds 50
         } else {
            Write-Progress -Activity "Resetting TaskManager preferences..." `
                -PercentComplete 100 `
                -Status "Done. $stage"

            Stop-Process -Name "taskmgr" -ErrorAction SilentlyContinue
            return $prefsBinary
        }
    }
}

function TaskManager {
    # Make sure we aren't messing with current user-made custom preferences,
    # otherwise invalid settings will result same behaviour as Invoke-TaskManagerPreferencesReset
    $prefsBinary = Invoke-TaskManagerPreferencesReset

    Write-Host 'Task Manager: Enable "More details"'
    $prefsBinary[28] = 0x00
    Write-Host 'Task Manager: Enable "Performance -> CPU -> Change graph to -> Logical Processors"'
    $prefsBinary[3480] = 0x01

    Write-Host 'Task Manager: Hide "Status" column'
    $prefsBinary[251] = 0x01
    Write-Host 'Task Manager: Hide "Power usage" column'
    $prefsBinary[867] = 0x09
    Write-Host 'Task Manager: Show "Command line" column'
    $prefsBinary[475] = 0x00
    # Each column index must be reassigned to change single column position
    $i = 1
    $prefsBinary[464+56*0] = 6
    for (; $i -ne 9; ++$i) { $prefsBinary[464+56*$i] = $prefsBinary[464+56*0] + ($i-1) }
    $prefsBinary[464+56*0] = $prefsBinary[464+56*($i-1)] + 1

    Set-RegistryValue -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager" `
    -Name "Preferences" -Value $prefsBinary -Type Binary -Force
}

# At ever first "detailed" launch, it seems, forcefully sets "Status" column.
function Invoke-TaskManagerTweaksApply {
    TaskManager
    TaskManager
}
