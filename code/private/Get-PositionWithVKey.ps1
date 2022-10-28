function Get-PositionWithVKey([Array]$MenuItems, [int]$Position, $VKeyCode) {
    $MinPosition = 0
    $MaxPosition = $MenuItems.Count - 1
    $WindowHeight = Get-ConsoleHeight 
    Set-Variable -Name NewPosition -Option AllScope -Value $Position

    function Reset-InvalidPosition([Parameter(Mandatory)][int] $PositionOffset) {
        $NewPosition = Get-WrappedPosition $MenuItems $NewPosition $PositionOffset
    }
    if (Test-KeyUp $VKeyCode) { 
        $NewPosition--
        Reset-InvalidPosition -PositionOffset -1
    }
    if (Test-KeyDown $VKeyCode) {
        $NewPosition++
        Reset-InvalidPosition -PositionOffset 1
    }
    if (Test-KeyPageDown $VKeyCode) {
        $NewPosition = [Math]::Min($MaxPosition, $NewPosition + $WindowHeight)
        Reset-InvalidPosition -PositionOffset -1
    }
    if (Test-KeyEnd $VKeyCode) {
        $NewPosition = $MenuItems.Count - 1
        Reset-InvalidPosition -PositionOffset 1
    }
    if (Test-KeyPageUp $VKeyCode) {
        $NewPosition = [Math]::Max($MinPosition, $NewPosition - $WindowHeight)
        Reset-InvalidPosition -PositionOffset -1
    }
    if (Test-KeyHome $VKeyCode) {
        $NewPosition = $MinPosition
        Reset-InvalidPosition -PositionOffset -1
    }
    return $NewPosition
}
Export-ModuleMember -Function Get-PositionWithVKey