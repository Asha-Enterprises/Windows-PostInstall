function Get-ConsoleHeight() {
    return (Get-Host).UI.RawUI.WindowSize.Height - 2
}
Export-ModuleMember -Function Get-ConsoleHeight