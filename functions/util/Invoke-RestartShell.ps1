function Invoke-RestartShell {
    Write-Host "Restarting explorer..."
    taskkill.exe /F /IM "explorer.exe"
    taskkill.exe /F /IM "ShellExperiencehost.exe"
    taskkill.exe /F /IM "StartMenuExperiencehost.exe"
    Remove-Item -Recurse -Verbose "$env:LocalAppData\Packages\Microsoft.Windows.ShellExperienceHost_cw5n1h2txyewy\TempState\*"
    Remove-Item -Recurse -Verbose "$env:LocalAppData\Packages\Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy\TempState\*"
    Start-Process "explorer.exe"
    Write-Host "Wait for Explorer to complete initialization."
}
