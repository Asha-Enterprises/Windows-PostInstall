function Install-AllPackages {
    param (
        [Parameter(Mandatory)]
        [string[]]$Packages
    )
    Write-Host $Packages
    foreach ($pkg in $Packages) {
        Write-Host ('Installing {0}...' -f $pkg) -ForegroundColor Green
        WinGet Install $pkg
    }
}
Export-ModuleMember -Function Install-AllPackages