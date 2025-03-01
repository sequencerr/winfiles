Get-ChildItem .\functions\util -File | ForEach-Object { . $_.FullName }
Get-ChildItem .\functions -File | ForEach-Object { . $_.FullName }

Invoke-UpdatesDisable
Invoke-AppsUninstall
Invoke-PerfomanceOptionsDisable
