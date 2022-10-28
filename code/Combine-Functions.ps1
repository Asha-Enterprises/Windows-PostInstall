Get-Content "$PSScriptRoot\Private\*.ps1" | Out-File -FilePath "$PSScriptRoot\Public\Post-InstallFunctions.psm1"
