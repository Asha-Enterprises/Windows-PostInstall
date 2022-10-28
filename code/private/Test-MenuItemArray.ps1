function Test-MenuItemArray([Array]$MenuItems) {
    foreach ($MenuItem in $MenuItems) {
        $IsSeparator = Test-MenuSeparator $MenuItem
        if ($IsSeparator -eq $false) {
            return
        }
    }
    Throw 'The -MenuItems option only contains non-selectable menu-items (like separators)'
}
Export-ModuleMember -Function Test-MenuItemArray