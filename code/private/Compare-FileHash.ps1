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