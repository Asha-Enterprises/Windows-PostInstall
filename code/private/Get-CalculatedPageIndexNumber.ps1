function Get-CalculatedPageIndexNumber(
    [Parameter(Mandatory, Position = 0)][Array] $MenuItems,
    [Parameter(Position = 1)][int]$MenuPosition,
    [switch]$TopIndex,
    [switch]$ItemCount,
    [switch]$BottomIndex
) {
    $WindowHeight = Get-ConsoleHeight
    $TopIndexNumber = 0;
    $MenuItemCount = $MenuItems.Count
    if ($MenuItemCount -gt $WindowHeight) {
        $MenuItemCount = $WindowHeight;
        if ($MenuPosition -gt $MenuItemCount) {
            $TopIndexNumber = $MenuPosition - $MenuItemCount;
        }
    }
    if ($TopIndex) {
        return $TopIndexNumber
    }
    if ($ItemCount) {
        return $MenuItemCount
    }
    if ($BottomIndex) {
        return $TopIndexNumber + [Math]::Min($MenuItemCount, $WindowHeight) - 1
    }
    Throw 'Invalid option combination'
}
Export-ModuleMember -Function Get-CalculatedPageIndexNumber