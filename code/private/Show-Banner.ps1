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
        Write-Host "                        ::" -NoNewLine -ForegroundColor Gray ; Write-Host "      https://github.com/Asha-Enterprises/Windows-PostInstall" -NoNewLine -ForegroundColor Yellow ; Write-Host "     ::" -ForegroundColor Gray
        Write-Host "                        ::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::" -ForegroundColor Gray
    }
}
Export-ModuleMember -Function Show-Banner