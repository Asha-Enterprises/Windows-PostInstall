function Get-Acronym() {
    param (
        [Parameter(Mandatory)][String]$InputText
    )
    PROCESS {
       $OutputText = (($InputText -split " " |ForEach-Object {$_[0]}) -join "")
       return $OutputText
    }
}