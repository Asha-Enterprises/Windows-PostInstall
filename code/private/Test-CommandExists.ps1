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