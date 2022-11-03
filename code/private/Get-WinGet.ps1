function Get-WinGet () {
    BEGIN {
        $ProgressPreference = 'SilentlyContinue'
        [string]$WinGetInstallFile = "$PSScriptRoot\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        [string]$WinGetInstallerURI = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        [string]$WinGetHashURI = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.txt"
        [string]$WinGetHashFile = "$PSScriptRoot\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.txt"
    }
    PROCESS {
        if ((Test-CommandExists WinGet) -eq $false) {
            if (!(Test-Path -Path $WinGetInstallFile -PathType Leaf)) {
                Write-Host "Downloading the latest WinGet installer..."
                Invoke-WebRequest -Uri $WinGetInstallerURI -OutFile $WinGetInstallFile
                Invoke-WebRequest -Uri $WinGetHashURI -OutFile $WinGetHashFile
                Write-Host -NoNewLine "Finished"
            }
            else {
                Write-Host "WinGet installer already exists."
            }
            if ((Compare-FileHash $WinGetHashFile $WinGetInstallFile) -eq $true) {
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