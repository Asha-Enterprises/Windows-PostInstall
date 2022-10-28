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
            if ((Compare-FileHash) -eq 0) {
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
function Install-AllPackages {
    param (
        [Parameter(Mandatory)]
        [string[]]$Packages
    )
    Write-Host $Packages
    foreach ($pkg in $Packages) {
        Write-Host ('Installing {0}...' -f $pkg) -ForegroundColor Green
        WinGet Install $pkg
    }
}
Export-ModuleMember -Function Install-AllPackages
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
        #Rename-Computer $NewComputerName -Force
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
