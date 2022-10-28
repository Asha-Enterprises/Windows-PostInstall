$Separator = [PSCustomObject]@{
    __MarkSeparator = [Guid]::NewGuid()
}
function Get-MenuSeparator() {
    [CmdletBinding()]
    Param()
    # Internally we will check this parameter by-reference
    return $Separator
}
Export-ModuleMember -Function Get-MenuSeparator