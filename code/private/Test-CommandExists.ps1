function Test-CommandExists{
    param(
        [Parameter(Position=0, Mandatory=$true)]
        $cmdName
    )
    try{
        if (Get-Command $cmdName -errorAction SilentlyContinue){
            return $false
        }
        else{
            return $true
        }
    }catch{
        throw $_.Exception.Message
    }     
}
Export-ModuleMember -Function Test-CommandExists