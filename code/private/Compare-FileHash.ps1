function Compare-FileHash {
    param ( 
        [Parameter(Mandatory)]
        [string[]]$FileWithHash,
        [string[]]$FileToHash
    )
    PROCESS {
        if ((Get-Content -Path $FileWithHash) -eq (Get-FileHash).Hash) {
            return $true
        }
        else {
            return $false
        }
    }
}
Export-ModuleMember -Function Compare-FileHash