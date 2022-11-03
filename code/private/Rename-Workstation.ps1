function Rename-Workstation {
    param (
        [Parameter(Mandatory)]
        [string[]]$CName,
        [string[]]$WType
    )
    BEGIN {
        [array]$ComputerNameInfo = @(
            [string]$CName
            [string]$WType
            (-join ((48..57) + (65..90) | Get-Random -Count 4 | ForEach-Object {[char]$_}))
        )
        $NewComputerName = $ComputerNameInfo -join "-"
    }
    PROCESS {
        Rename-Computer $NewComputerName -Force
    }
    END {
        return $NewComputerName
    }
}
Export-ModuleMember -Function Rename-Workstation