function Show-Menu {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory, Position = 0)][Array] $MenuItems,
        [switch]$ReturnIndex, 
        [switch]$MultiSelect, 
        [ConsoleColor] $ItemFocusColor = [ConsoleColor]::Green,
        [ScriptBlock] $MenuItemFormatter = { Param($M) Format-MenuItemDefault $M },
        [Array] $InitialSelection = @(),
        [ScriptBlock] $Callback = $null
    )
    Test-HostSupported
    Test-MenuItemArray -MenuItems $MenuItems
    # Current pressed virtual key code
    $VKeyCode = 0
    # Initialize valid position
    $Position = Get-WrappedPosition $MenuItems -Position 0 -PositionOffset 1
    $CurrentSelection = $InitialSelection   
    try {
        [System.Console]::CursorVisible = $False # Prevents cursor flickering
        # Body
        $WriteMenu = {
            ([ref]$MenuHeight).Value = Write-Menu -MenuItems $MenuItems `
                -MenuPosition $Position `
                -MultiSelect:$MultiSelect `
                -CurrentSelection:$CurrentSelection `
                -ItemFocusColor $ItemFocusColor `
                -MenuItemFormatter $MenuItemFormatter
        }
        $MenuHeight = 0
        & $WriteMenu
        $NeedRendering = $false        
        while ($True) {
            if (Test-KeyEscape $VKeyCode) {
                return $null
            }
            if (Test-KeyEnter $VKeyCode) {
                Break
            }
            # while there are 
            do {
                # Read key when callback and available key, or no callback at all
                $VKeyCode = $null
                if ($null -eq $Callback -or [Console]::KeyAvailable) {
                    $CurrentPress = Read-VKey
                    $VKeyCode = $CurrentPress.VirtualKeyCode
                }
                if (Test-KeySpace $VKeyCode) {
                    $CurrentSelection = Toggle-Selection $Position $CurrentSelection
                }
                $Position = Get-PositionWithVKey -MenuItems $MenuItems -Position $Position -VKeyCode $VKeyCode
                if (!$(Test-KeyEscape $VKeyCode)) {
                    [System.Console]::SetCursorPosition(0, [Math]::Max(0, [Console]::CursorTop - $MenuHeight))
                    $NeedRendering = $true
                }
            } while ($null -eq $Callback -and [Console]::KeyAvailable);
            if ($NeedRendering) {
                & $WriteMenu
                $NeedRendering = $false
            }
            if ($Callback) {
                & $Callback
                Start-Sleep -Milliseconds 10
            }
        }
    }
    finally {
        [System.Console]::CursorVisible = $true
    }
    if ($ReturnIndex -eq $false -and $null -ne $Position) {
        if ($MultiSelect) {
            if ($null -ne $CurrentSelection) {
                return $MenuItems[$CurrentSelection]
            }
        }
        else {
            return $MenuItems[$Position]
        }
    }
    else {
        if ($MultiSelect) {
            return $CurrentSelection
        }
        else {
            return $Position
        }
    }
}
Export-ModuleMember -Function Show-Menu