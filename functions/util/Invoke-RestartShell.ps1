Add-Type @"
        using System;
        using System.Runtime.InteropServices;
        public class Win32 {
            [DllImport("user32.dll")]
            public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        }
"@

function Invoke-RestartShell {
    Write-Host "Restarting explorer..."
    taskkill.exe /F /IM "explorer.exe"
    taskkill.exe /F /IM "ShellExperiencehost.exe"
    taskkill.exe /F /IM "StartMenuExperiencehost.exe"
    Remove-Item -Recurse -Verbose "$env:LocalAppData\Packages\Microsoft.Windows.ShellExperienceHost_cw5n1h2txyewy\TempState\*"
    Remove-Item -Recurse -Verbose "$env:LocalAppData\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\TempState\*"
    Start-Process "explorer.exe"

    while ($True) {
        # Check if shell is responsive by testing Desktop folder available
        # Also check if taskbar is available by looking for its window
        $desktop = (New-Object -ComObject Shell.Application).NameSpace(0)
        $taskbarHandle = [Win32]::FindWindow("Shell_TrayWnd", $null)
        if ($desktop -and $taskbarHandle -ne [IntPtr]::Zero) {
            Write-Output "Desktop environment should be initialized."
            break
        }
        Write-Host "Waititing for Explorer to complete initialization..."
        Start-Sleep -Milliseconds 100
    }
}
