Get-ChildItem .\functions\ -File | ForEach-Object { . $_.FullName }

Invoke-UpdatesDisable
Invoke-AppsUninstall
Invoke-PerfomanceOptionsDisable
