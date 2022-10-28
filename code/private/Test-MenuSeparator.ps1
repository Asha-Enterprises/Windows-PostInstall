function Test-MenuSeparator([Parameter(Mandatory)] $MenuItem) {
    $Separator = Get-MenuSeparator

    # Separator is a singleton and we compare it by reference
    return [Object]::ReferenceEquals($Separator, $MenuItem)
}
Export-ModuleMember -Function Test-MenuSeparator