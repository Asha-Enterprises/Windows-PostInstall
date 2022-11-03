function Compare-FileHash {
    param ( 
        [Parameter(Mandatory)]
        [string[]]$FileWithHash,
        [string[]]$FileToHash
    )
    PROCESS {
        if ((Get-Content -Path $FileWithHash) -eq (Get-FileHash).Hash) {
            return 0
        }
        else {
            return 1
        }
    }
}
Export-ModuleMember -Function Compare-FileHash
function Format-MenuItem(
    [Parameter(Mandatory)] $MenuItem, 
    [switch] $MultiSelect, 
    [Parameter(Mandatory)][bool] $IsItemSelected, 
    [Parameter(Mandatory)][bool] $IsItemFocused) {
    $SelectionPrefix = '    '
    $FocusPrefix = '  '
    $ItemText = ' -------------------------- '
    if ($(Test-MenuSeparator $MenuItem) -ne $true) {
        if ($MultiSelect) {
            $SelectionPrefix = if ($IsItemSelected) { '[x] ' } else { '[ ] ' }
        }
        $FocusPrefix = if ($IsItemFocused) { '> ' } else { '  ' }
        $ItemText = $MenuItem.ToString()
    }
    $WindowWidth = (Get-Host).UI.RawUI.WindowSize.Width
    $Text = "{0}{1}{2}" -f $FocusPrefix, $SelectionPrefix, $ItemText
    if ($WindowWidth - ($Text.Length + 2) -gt 0) {
        $Text = $Text.PadRight($WindowWidth - ($Text.Length + 2), ' ')
    }    
    return $Text
}
function Format-MenuItemDefault($MenuItem) {
    return $MenuItem.ToString()
}
Export-ModuleMember -Function Format-MenuItem, Format-MenuItemDefault
function Get-Acronym() {
    param (
        [Parameter(Mandatory)][String]$InputText
    )
    PROCESS {
       $OutputText = (($InputText -split " " |ForEach-Object {$_[0]}) -join "")
       return $OutputText
    }
}
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
function Get-ConsoleHeight() {
    return (Get-Host).UI.RawUI.WindowSize.Height - 2
}
Export-ModuleMember -Function Get-ConsoleHeight
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
function Get-WinGet () {
    BEGIN {
        $ProgressPreference = 'SilentlyContinue'
        $WinGetInstallFile = "$PSScriptRoot\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $WinGetInstallerURI = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $WinGetHashURI = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.txt"
        $WinGetHashFile = "$PSScriptRoot\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.txt"
    }
    PROCESS {
        if ((Test-CommandExists WinGet) -eq 0) {
            if (!(Test-Path -Path $WinGetInstallFile -PathType Leaf)) {
                Write-Host "Downloading the latest WinGet installer..."
                Invoke-WebRequest -Uri $WinGetInstallerURI -OutFile $WinGetInstallFile
                Invoke-WebRequest -Uri $WinGetHashURI -OutFile $WinGetHashFile
                Write-Host -NoNewLine "Finished"
            }
            else {
                Write-Host "WinGet installer already exists."
            }
            if ((Compare-FileHash $WinGetHashFile $WinGetInstallFile) -eq 0) {
                Add-AppPackage -Path $WinGetInstallFile
            }
            else {
                Write-Error -Message "Error: Hashes did not match"
            }
        }
        else {
            return "WinGet is already installed."
        }
    }
    END {}
}
Export-ModuleMember -Function Get-WinGet
function  Get-WrappedPosition([Array]$MenuItems, [int]$Position, [int]$PositionOffset) {
    # Wrap position
    if ($Position -lt 0) {
        $Position = $MenuItems.Count - 1
    }
    if ($Position -ge $MenuItems.Count) {
        $Position = 0
    }
    # Ensure to skip separators
    while (Test-MenuSeparator $($MenuItems[$Position])) {
        $Position += $PositionOffset
        $Position = Get-WrappedPosition $MenuItems $Position $PositionOffset
    }
    return $Position
}
Export-ModuleMember -Function Get-WrappedPosition
function Install-AllPackages {
    param (
        [Parameter(Mandatory)]
        [string[]]$Packages
    )
    Write-Host $Packages
    foreach ($pkg in $Packages) {
        Write-Host ('Installing {0}...' -f $pkg) -ForegroundColor Green
        WinGet Install $pkg -h
    }
}
Export-ModuleMember -Function Install-AllPackages
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
function Read-VKey() {
    $CurrentHost = Get-Host
    $ErrMsg = "Current host '$CurrentHost' does not support operation 'ReadKey'"
    try {
        # Issues with reading up and down arrow keys
        # - https://github.com/PowerShell/PowerShell/issues/16443
        # - https://github.com/dotnet/runtime/issues/63387
        # - https://github.com/PowerShell/PowerShell/issues/16606
        if ($IsLinux -or $IsMacOS) {
            ## A bug with Linux and Mac where arrow keys are return in 2 chars.  First is esc follow by A,B,C,D
            $key1 = $CurrentHost.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")          
            if ($key1.VirtualKeyCode -eq 0x1B) {
                ## Found that we got an esc chair so we need to grab one more char
                $key2 = $CurrentHost.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
                ## We just care about up and down arrow mapping here for now.
                if ($key2.VirtualKeyCode -eq 0x41) {
                    # VK_UP = 0x26 up-arrow
                    $key1.VirtualKeyCode = 0x26
                }
                if ($key2.VirtualKeyCode -eq 0x42) {
                    # VK_DOWN = 0x28 down-arrow
                    $key1.VirtualKeyCode = 0x28
                }
            }
            return $key1
        }       
        return $CurrentHost.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    catch [System.NotSupportedException] {
        Write-Error -Exception $_.Exception -Message $ErrMsg
    }
    catch [System.NotImplementedException] {
        Write-Error -Exception $_.Exception -Message $ErrMsg
    }
}
Export-ModuleMember -Function Read-VKey
function Rename-Workstation {
    param (
        [Parameter(Mandatory)]
        [string[]]$CName
    )
    BEGIN {
        $ComputerNameInfo = @(
            $CName
            (((Get-CimInstance Win32_BaseBoard).Manufacturer).Substring(0,4)).ToUpper()
            (-join ((48..57) + (65..90) | Get-Random -Count 4 | ForEach-Object {[char]$_}))
        )
        $NewComputerName = $ComputerNameInfo[0]+'-'+$ComputerNameInfo[1]+'-'+$ComputerNameInfo[2]
    }
    PROCESS {
        Rename-Computer $NewComputerName -Force
    }
    END {
        return $NewComputerName
    }
}
Export-ModuleMember -Function Rename-Workstation
function Show-Banner { 
    Clear-Host
    $Host.UI.RawUI.ForegroundColor = 'Gray'
    if ($nogui -like '-nogui'){ 
        $null
    }else { 
        Write-Host
        Write-Host " __      __.__            .___                  " -NoNewLine -ForegroundColor Magenta ; Write-Host "__________               __ " -NoNewLine  ; Write-Host " .___                 __         .__  .__   " -ForegroundColor Magenta
        Write-Host "/  \    /  \__| ____    __| _/______  _  _______" -NoNewLine -ForegroundColor Magenta ; Write-Host "\______   \____  _______/  |_" -NoNewLine  ; Write-Host "|   | ____   _______/  |______  |  | |  |  " -ForegroundColor Magenta
        Write-Host "\   \/\/   /  |/    \  / __ |/  _ \ \/ \/ /  ___/" -NoNewLine -ForegroundColor Magenta ;  Write-Host "|     ___/  _ \/  ___/\   __\" -NoNewLine ; Write-Host "   |/    \ /  ___/\   __\__  \ |  | |  |  " -ForegroundColor Magenta
        Write-Host " \        /|  |   |  \/ /_/ (  <_> )     /\___ \ " -NoNewLine -ForegroundColor Magenta ;  Write-Host "|    |  (  <_> )___ \  |  | " -NoNewLine ; Write-Host "|   |   |  \\___ \  |  |  / __ \|  |_|  |__" -ForegroundColor Magenta
        Write-Host "  \__/\  / |__|___|  /\____ |\____/ \/\_//____  >" -NoNewLine -ForegroundColor Magenta ;  Write-Host "|____|   \____/____  > |__| " -NoNewLine ; Write-Host "|___|___|  /____  > |__| (____  /____/____/" -ForegroundColor Magenta
        Write-Host "       \/          \/      \/                 \/  " -NoNewLine -ForegroundColor Magenta ; Write-Host "                  \/        " -NoNewLine  ; Write-Host "        \/     \/            \/           " -ForegroundColor Magenta
        Write-Host
        Write-Host "                        ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::" -ForegroundColor Gray
        Write-Host "                        ::" -NoNewLine -ForegroundColor Gray ; Write-Host "  Windows Post Installation Script" -NoNewLine -ForegroundColor Yellow ; Write-Host "  :: " -NoNewLine -ForegroundColor Gray ; Write-Host " Created by @mbussardcc" -NoNewLine -ForegroundColor Yellow ; Write-Host "    ::" -ForegroundColor Gray
        Write-Host "                        ::" -NoNewLine -ForegroundColor Gray ; Write-Host "      https://github.com/Asha-Enterprises/powershell-scripts" -NoNewLine -ForegroundColor Yellow ; Write-Host "      ::" -ForegroundColor Gray
        Write-Host "                        ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::" -ForegroundColor Gray
    }
}
Export-ModuleMember -Function Show-Banner
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
function Test-CommandExists{
    param(
        [Parameter(Position=0, Mandatory=$true)]
        $cmdName
    )
    try{
        if (Get-Command $cmdName -errorAction SilentlyContinue){
            return 1
        }
        else{
            return 0
        }
    }catch{
        throw $_.Exception.Message
    }     
}
Export-ModuleMember -Function Test-CommandExists
function Test-HostSupported() {
    $Whitelist = @("ConsoleHost")
    if ($Whitelist -inotcontains $Host.Name) {
        Throw "This host is $($Host.Name) and does not support an interactive menu."
    }
}
Export-ModuleMember -Function Test-HostSupported
function Test-HostSupported() {
    $Whitelist = @("ConsoleHost")
    if ($Whitelist -inotcontains $Host.Name) {
        Throw "This host is $($Host.Name) and does not support an interactive menu."
    }
}
# Ref: https://docs.microsoft.com/en-us/windows/desktop/inputdev/virtual-key-codes
$KeyConstants = [PSCustomObject]@{
    VK_RETURN   = 0x0D;
    VK_ESCAPE   = 0x1B;
    VK_UP       = 0x26;
    VK_DOWN     = 0x28;
    VK_SPACE    = 0x20;
    VK_PAGEUP   = 0x21; # Actually VK_PRIOR
    VK_PAGEDOWN = 0x22; # Actually VK_NEXT
    VK_END      = 0x23;
    VK_HOME     = 0x24;
}
function Test-KeyEnter($VKeyCode) {
    return $VKeyCode -eq $KeyConstants.VK_RETURN
}
function Test-KeyEscape($VKeyCode) {
    return $VKeyCode -eq $KeyConstants.VK_ESCAPE
}
function Test-KeyUp($VKeyCode) {
    return $VKeyCode -eq $KeyConstants.VK_UP
}
function Test-KeyDown($VKeyCode) {
    return $VKeyCode -eq $KeyConstants.VK_DOWN
}
function Test-KeySpace($VKeyCode) {
    return $VKeyCode -eq $KeyConstants.VK_SPACE
}
function Test-KeyPageDown($VKeyCode) {
    return $VKeyCode -eq $KeyConstants.VK_PAGEDOWN
}
function Test-KeyPageUp($VKeyCode) {
    return $VKeyCode -eq $KeyConstants.VK_PAGEUP
}
function Test-KeyEnd($VKeyCode) {
    return $VKeyCode -eq $KeyConstants.VK_END
}
function Test-KeyHome($VKeyCode) {
    return $VKeyCode -eq $KeyConstants.VK_HOME
}
Export-ModuleMember -Function Test-HostSupported
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
function Test-MenuSeparator([Parameter(Mandatory)] $MenuItem) {
    $Separator = Get-MenuSeparator

    # Separator is a singleton and we compare it by reference
    return [Object]::ReferenceEquals($Separator, $MenuItem)
}
Export-ModuleMember -Function Test-MenuSeparator
function Toggle-Selection {
    param ($Position, [Array]$CurrentSelection)
    if ($CurrentSelection -contains $Position) { 
        $result = $CurrentSelection | where { $_ -ne $Position }
    }
    else {
        $CurrentSelection += $Position
        $result = $CurrentSelection
    }  
    return $Result
}
Export-ModuleMember -Function Toggle-Selection
function Write-MenuItem(
    [Parameter(Mandatory)][String] $MenuItem,
    [switch]$IsFocused,
    [ConsoleColor]$FocusColor) {
    if ($IsFocused) {
        Write-Host $MenuItem -ForegroundColor $FocusColor
    }
    else {
        Write-Host $MenuItem
    }
}
function Write-Menu {
    param (
        [Parameter(Mandatory)][Array] $MenuItems, 
        [Parameter(Mandatory)][Int] $MenuPosition,
        [Parameter()][Array] $CurrentSelection, 
        [Parameter(Mandatory)][ConsoleColor] $ItemFocusColor,
        [Parameter(Mandatory)][ScriptBlock] $MenuItemFormatter,
        [switch] $MultiSelect
    )   
    $CurrentIndex = Get-CalculatedPageIndexNumber -MenuItems $MenuItems -MenuPosition $MenuPosition -TopIndex
    $MenuItemCount = Get-CalculatedPageIndexNumber -MenuItems $MenuItems -MenuPosition $MenuPosition -ItemCount
    $ConsoleWidth = [Console]::BufferWidth
    $MenuHeight = 0
    for ($i = 0; $i -le $MenuItemCount; $i++) {
        if ($null -eq $MenuItems[$CurrentIndex]) {
            Continue
        }
        $RenderMenuItem = $MenuItems[$CurrentIndex]
        $MenuItemStr = if (Test-MenuSeparator $RenderMenuItem) { $RenderMenuItem } else { & $MenuItemFormatter $RenderMenuItem }
        if (!$MenuItemStr) {
            Throw "'MenuItemFormatter' returned an empty string for item #$CurrentIndex"
        }
        $IsItemSelected = $CurrentSelection -contains $CurrentIndex
        $IsItemFocused = $CurrentIndex -eq $MenuPosition
        $DisplayText = Format-MenuItem -MenuItem $MenuItemStr -MultiSelect:$MultiSelect -IsItemSelected:$IsItemSelected -IsItemFocused:$IsItemFocused
        Write-MenuItem -MenuItem $DisplayText -IsFocused:$IsItemFocused -FocusColor $ItemFocusColor
        $MenuHeight += [Math]::Max([Math]::Ceiling($DisplayText.Length / $ConsoleWidth), 1)
        $CurrentIndex++;
    }
    $MenuHeight
}
Export-ModuleMember -Function Write-MenuItem, Write-Menu
