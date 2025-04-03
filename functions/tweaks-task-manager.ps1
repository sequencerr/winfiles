# https://superuser.com/questions/930195/force-windows-8-1-task-manager-to-always-show-more-details
# https://www.reddit.com/r/pcmasterrace/comments/3oavq0/something_about_task_manager_that_grinds_my_gears/

$signature = @"
    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
"@
$WinAPI = Add-Type -MemberDefinition $signature -Name "WinAPI" -Namespace "WinAPI" -PassThru

Add-Type -AssemblyName System.Windows.Forms;

function Invoke-TaskManagerPreferencesReset {
    Stop-Process -Name "taskmgr" -Force -ErrorAction SilentlyContinue

    Remove-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager\Preferences" -Force -ErrorAction SilentlyContinue
    $process = Start-Process "taskmgr.exe" -PassThru

    do {
        Start-Sleep -Milliseconds 200
        $window = Get-Process -Id $process.Id -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne 0 }
    } until ($window)

    $WinAPI::SetForegroundWindow($window.MainWindowHandle) | Out-Null

    [System.Windows.Forms.SendKeys]::SendWait('{ESC}')
    Stop-Process -Name "taskmgr" -ErrorAction SilentlyContinue

    if ($null -eq (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue).Preferences) {
        Write-Host "Unable to get current TaskManager preferences" -ForegroundColor Red;
        return
    }
}

function Invoke-TaskManagerTweaksApply {
    # Make sure we aren't messing with current user-made custom preferences,
    # otherwise invalid settings will result same behaviour as Invoke-TaskManagerPreferencesReset
    Invoke-TaskManagerPreferencesReset

    $prefsBinary = (Get-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager" -Name "Preferences" -ErrorAction SilentlyContinue).Preferences
    if ($null -eq $prefsBinary) { Write-Host "Unable to get current TaskManager preferences" -ForegroundColor Red; return }

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
    for (; $i -ne 9; ++$i) { $prefsBinary[464+56*$i] = $prefsBinary[464+56*0] + ($i-1)  }
    $prefsBinary[464+56*0] = $prefsBinary[464+56*($i-1)] + 1

    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\TaskManager" `
    -Name "Preferences" -Value $prefsBinary -Type Binary
}
