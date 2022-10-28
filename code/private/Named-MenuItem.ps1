class NamedMenuOption {
    [String]$DisplayName
    [String]$PackageID

    [String]ToString() {
        Return $This.DisplayName
    }
}

# Menu display name function
function Named-MenuItem([String]$DisplayName, [String]$PackageID) {
    $MenuItem = [NamedMenuOption]::new()
    $MenuItem.DisplayName = $DisplayName
    $MenuItem.PackageID = $PackageID
    Return $MenuItem
}
Export-ModuleMember -Function Named-MenuItem