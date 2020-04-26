. "$PSScriptRoot\config.ps1"

Write-Host "Starting to provision VM according to config.ps1"

# sshd (it is already installed, but not activated)
Write-Host "- Enable and start sshd"
Set-Service -Name sshd -StartupType Automatic
Start-Service -Name sshd

# Remote Desktop (RDP)
Write-Host "- Enable and start Remote Desktop"
Set-ItemProperty -Path "HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server" -name fDenyTSConnections -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Auto-Logon
Write-Host "- Enable automatic logon for account IEUser"
Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" -Name AutoAdminLogon -Value 1
Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" -Name DefaultUserName -Value "IEUser"
Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" -Name DefaultPassword -Value "Passw0rd!"

# Windows-Update
# https://docs.microsoft.com/security-updates/windowsupdateservices/18127499
Write-Host "- Disable automatic search and installation of Windows Updates: $disableWindowsAutoUpdate"
if ($disableWindowsAutoUpdate) {
    $windowsUpdatePath = "HKLM:\\Software\\Policies\\Microsoft\\Windows\\WindowsUpdate"
    if (!(Test-Path $windowsUpdatePath)) {
        New-Item -Path $windowsUpdatePath -Force | Out-Null
    }
    Set-ItemProperty -Path $windowsUpdatePath -Name NoAutoUpdate -Type DWord -Value 1
    Set-ItemProperty -Path $windowsUpdatePath -Name AUOptions -Type DWord -Value 2
}

# DPI-Scaling:
# 0 (100%, 96dpi); 1 (125%, 120dpi); 2 (150%, 144dpi); 3 (175%, 168dpi); 4 (200%, 192dpi)
Write-Host "- Set scaling to: $dpiScaling"
$perMonitorSettings = "HKCU:\\Control Panel\\Desktop\\PerMonitorSettings"
$monitorPath = "$perMonitorSettings\\NOEDID_80EE_BEEF_00000000_00020000_0^8EBF71A8F8FA6B5415313805363EA384"
if (!(Test-Path $monitorPath)) {
    New-Item -Path $monitorPath -Force | Out-Null
}
Set-ItemProperty -Path $monitorPath -Name "DpiValue" -Type DWord -Value $dpiScaling

# Dark-Mode!
# Unfortunately, I don't know yet how to activate the dark mode of Edge
Write-Host "- Enable Dark Mode: $darkMode"
$useLightTheme = If ($darkMode) { 0 } Else { 1 }
Set-ItemProperty -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" -Name AppsUseLightTheme -Value $useLightTheme

# hosts:
Write-Host "- Set content of $env:windir\System32\drivers\etc\hosts to:"
Write-Host $hostsFile
Set-Content -Path "$env:windir\System32\drivers\etc\hosts" -Value $hostsFile -Force

# To get the list of time zones: Get-TimeZone -ListAvailable
# Or here: https://support.microsoft.com/en-us/help/973627/microsoft-time-zone-index-values
Write-Host "- Set time zone to: $timeZone"
Set-TimeZone -Id $timeZone

# System locale
Write-Host "- Set system locate to: $locale"
Set-WinSystemLocale -SystemLocale $locale

# Region
# https://docs.microsoft.com/windows/win32/intl/table-of-geographical-locations
# Germany: 0x5e, USA: 0xF4
Write-Host "- Set region to: $region"
Set-WinHomeLocation -GeoId $region

# Regional format
Write-Host "- Set regional format to: $locale"
Set-Culture -CultureInfo $locale

# Language and Keyboard
# https://docs.microsoft.com/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs
# en-US: 0x0409; de-DE: 0x0407
# $languages = "de-DE", "en-US"
# https://docs.microsoft.com/windows-hardware/manufacture/desktop/windows-language-pack-default-values
# English (International): 0x00020409; English (US): 0x00000409; German: 0x00000407
# $keyboards = 0x407, 0x20409

Write-Host "- Enable languages `"$languages`" with keyboards `"$keyboards`" (KLIDs) as input methods."
function Language-To-LCID {
    param ([Parameter(Mandatory=$true,ValueFromPipeline=$true)][String]$language)

    $cultureInfo = New-Object system.globalization.cultureinfo($language)
    return $cultureInfo.LCID
}

$languageList = New-WinUserLanguageList -Language $languages[0]
foreach ($language in $languages | Select-Object -Skip 1) {
    $languageList.Add($language)
}

foreach ($language in $languageList) {
    $lcid = $language.LanguageTag | Language-To-LCID
    $language.InputMethodTips.Clear()
    $keyboards | % { "{0:x}:{1:x}" -f $lcid, $_ } | % { $language.InputMethodTips.Add($_) }
}

Set-WinUserLanguageList $languageList -Force
