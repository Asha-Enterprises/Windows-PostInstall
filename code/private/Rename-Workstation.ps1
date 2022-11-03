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