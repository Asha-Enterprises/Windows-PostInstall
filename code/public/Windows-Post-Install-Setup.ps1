<#

    .SYNOPSIS
        Windows post-install setup and configuration script
    .DESCRIPTION
        Script designed to ease post Windows install tasks such as base program installation, computer renaming, domain joining, and more. 
        Features will be added as time allows and ideas come to mind or suggested.
    .NOTES
        Author: mbussardcc
    .LINK
        https://github.com/Asha-Enterprises/powershell-scripts
    
#>

# Module imports
#Import-Module -Name "$PSScriptRoot\Post-InstallMenuFunctions.psm1"
Import-Module -Name "$PSScriptRoot\Post-InstallFunctions.psm1"

# Powershell menu items
[array]$PackageOptions = @(
    $(Named-MenuItem -DisplayName "Adobe Reader DC" -PackageID "Adobe.Acrobat.Reader.64-bit")
    $(Named-MenuItem -DisplayName "LibreOffice" -PackageID "TheDocumentFoundation.LibreOffice")
    $(Named-MenuItem -DisplayName "ONLYOFFICE" -PackageID "ONLYOFFICE.DesktopEditors")
    $(Named-MenuItem -DisplayName "Microsoft Office" -PackageID "Microsoft.Office")
    $(Named-MenuItem -DisplayName "Microsoft Teams" -PackageID "Microsoft.Teams")
    $(Named-MenuItem -DisplayName "Thunderbird" -PackageID "Mozilla.Thunderbird")
    $(Named-MenuItem -DisplayName "Notepad++" -PackageID "Notepad++.Notepad++")
    $(Named-MenuItem -DisplayName "Zoom" -PackageID "Zoom.Zoom")
    $(Get-MenuSeparator)
    $(Named-MenuItem -DisplayName "7zip" -PackageID "7zip.7zip")
    $(Named-MenuItem -DisplayName "CCleaner" -PackageID "Piriform.CCleaner")
    $(Named-MenuItem -DisplayName "CrystalDiskInfo" -PackageID "CrystalDewWorld.CrystalDiskInfo")
    $(Get-MenuSeparator)
    $(Named-MenuItem -DisplayName "1Password" -PackageID "AgileBits.1Password")
    $(Named-MenuItem -DisplayName "Bitwarden" -PackageID "Bitwarden.Bitwarden")
    $(Named-MenuItem -DisplayName "KeePass" -PackageID "DominikReichl.KeePass")
    $(Named-MenuItem -DisplayName "Keeper Desktop" -PackageID "Keeper.KeeperDesktop")
    $(Get-MenuSeparator)
    $(Named-MenuItem -DisplayName "Google Chrome" -PackageID "Google.Chrome")
    $(Named-MenuItem -DisplayName "Libre Wolf" -PackageID "LibreWolf.LibreWolf")
    $(Named-MenuItem -DisplayName "Mozilla Firefox" -PackageID "Mozilla.Firefox")
    $(Named-MenuItem -DisplayName "Vivaldi" -PackageID "VivaldiTechnologies.Vivaldi")
    $(Get-MenuSeparator)
    $(Named-MenuItem -DisplayName "Dropbox" -PackageID "Dropbox.Dropbox")
    $(Named-MenuItem -DisplayName "GitHub Desktop" -PackageID "GitHub.GitHubDesktop")
    $(Named-MenuItem -DisplayName "Google Drive" -PackageID "Google.Drive")
    $(Get-MenuSeparator)
    $(Named-MenuItem -DisplayName "Epic Games Launcher" -PackageID "EpicGames.EpicGamesLauncher")
    $(Named-MenuItem -DisplayName "GOG Galaxy" -PackageID "GOG.Galaxy")
    $(Named-MenuItem -DisplayName "Steam" -PackageID "Valve.Steam")
    $(Get-MenuSeparator)
    $(Named-MenuItem -DisplayName "ESET NOD32" -PackageID "ESET.Nod32")
    $(Named-MenuItem -DisplayName "ESET Security" -PackageID "ESET.Security")
    $(Named-MenuItem -DisplayName "Malwarebytes" -PackageID "Malwarebytes.Malwarebytes")
    $(Get-MenuSeparator)
    $(Named-MenuItem -DisplayName "Git" -PackageID "Git.Git")
    $(Named-MenuItem -DisplayName "Java 8" -PackageID "Oracle.JavaRuntimeEnvironment")
    $(Named-MenuItem -DisplayName "K-LiteCodecPack Standard" -PackageID "CodecGuide.K-LiteCodecPack.Standard")
    $(Named-MenuItem -DisplayName "Python 3.10" -PackageID "Python.Python.3.10")
    $(Get-MenuSeparator)
    $(Named-MenuItem -DisplayName "AWS VPN Client" -PackageID "Amazon.AWSVPNClient")
    $(Named-MenuItem -DisplayName "FortiClient VPN" -PackageID "Fortinet.FortiClientVPN")
    $(Named-MenuItem -DisplayName "OpenVPN Client" -PackageID "OpenVPNTechnologies.OpenVPN")
    $(Named-MenuItem -DisplayName "SonicWall NetExtender" -PackageID "SonicWALL.NetExtender")
    $(Named-MenuItem -DisplayName "Tailscale" -PackageID "tailscale.tailscale")
    $(Named-MenuItem -DisplayName "WireGuard Client" -PackageID "WireGuard.WireGuard")
    $(Get-MenuSeparator)
    $(Named-MenuItem -DisplayName "Unigine Heaven" -PackageID "Unigine.HeavenBenchmark")
    $(Named-MenuItem -DisplayName "Unigine Superposition" -PackageID "Unigine.SuperpositionBenchmark")
    $(Named-MenuItem -DisplayName "Unigine Valley" -PackageID "Unigine.ValleyBenchmark")
)

#Banner and welcome message
Show-Banner
Write-Host "Welcome to the post Windows installation script. Fasten your seat belts and prepare for take off."
Start-Sleep -Seconds 2

#Test if WinGet is already installed. If not, install it.
Get-WinGet
Start-Sleep -Seconds 2

#Package selection section
$PackageSectionCounter = 0
do {
    $InstallPackagesQ = $(Read-Host "Would you like to install packages? [y/n]")
    if ($InstallPackagesQ -eq 'y') {
        $PackageSelection = Show-Menu -MenuItems $PackageOptions -MultiSelect
        #Install selected packages
        if ($null -ne $PackageSelection) {
            #Install-AllPackages $PackageSelection
            Write-Host $PackageSelection
        }
        $PackageSectionCounter++
    }
    elseif ($InstallPackagesQ -eq 'n') {
        $PackageSectionCounter++
        #Write-Host $PackageSectionCounter
    }
    else {
        $PackageSectionCounter--
        #Write-Host $PackageSectionCounter
    }
}until (++$PackageSectionCounter -gt 0)


#Rename computer section
$RenameComputerSectionCounter = 0
do {
    $RenameComputerQ = $(Read-Host "Would you like to rename computer? [y/n] ")
    if ($RenameComputerQ -eq 'y') {
        $ComputerNameQ = $(Read-Host "Enter client name acronymized: ").ToUpper()
        if ($null -ne $ComputerNameQ) {
            #Rename-Workstation $ComputerNameQ
            Write-Host $ComputerNameQ
        }
        $RenameComputerSectionCounter++
        #Write-Host $RenameComputerSectionCounter
    }
    elseif ($RenameComputerQ -eq 'n') {
        $RenameComputerSectionCounter++
        #Write-Host $RenameComputerSectionCounter
    }
    else {
        $RenameComputerSectionCounter--
        #Write-Host $RenameComputerSectionCounter
    }
}until (++$RenameComputerSectionCounter -gt 0)

#Restart computer section
$RestartComputerSectionCounter = 0
do {
    $RestartComputerQ = $(Read-Host "Would you like to restart the computer? [y/n] ")
    if ($RestartComputerQ -eq 'y') {
        #Restart-Computer -Force
        $RestartComputerSectionCounter++
        #Write-Host $RestartComputerSectionCounter
    }

    elseif ($RestartComputerQ -eq 'n') {
        $RestartComputerSectionCounter++
        #Write-Host $RestartComputerSectionCounter
    }
    else {
        $RestartComputerSectionCounter--
        #Write-Host $RestartComputerSectionCounter
    }
}until (++$RestartComputerSectionCounter -gt 0)