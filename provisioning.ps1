# sshd (it is already installed, but not activated)
Set-Service -Name sshd -StartupType Automatic
Start-Service -Name sshd

# Remote Desktop (RDP)
Set-ItemProperty -Path "HKLM:\\System\\CurrentControlSet\\Control\\Terminal Server" -name fDenyTSConnections -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Auto-Logon
Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" -Name AutoAdminLogon -Value 1
Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" -Name DefaultUserName -Value "IEUser"
Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion\\Winlogon" -Name DefaultPassword -Value "Passw0rd!"

# Windows-Update
# https://docs.microsoft.com/security-updates/windowsupdateservices/18127499
$windowsUpdatePath = "HKLM:\\Software\\Policies\\Microsoft\\Windows\\WindowsUpdate"
if (!(Test-Path $windowsUpdatePath)) {
    New-Item -Path $windowsUpdatePath -Force | Out-Null
}
Set-ItemProperty -Path $windowsUpdatePath -Name NoAutoUpdate -Type DWord -Value 1
Set-ItemProperty -Path $windowsUpdatePath -Name AUOptions -Type DWord -Value 2 

# DPI-Scaling:
# 0 (100%, 96dpi); 1 (125%, 120dpi); 2 (150%, 144dpi); 3 (175%, 168dpi); 4 (200%, 192dpi)
$perMonitorSettings = "HKCU:\\Control Panel\\Desktop\\PerMonitorSettings"
$monitorPath = "$perMonitorSettings\\NOEDID_80EE_BEEF_00000000_00020000_0^8EBF71A8F8FA6B5415313805363EA384"
if (!(Test-Path $monitorPath)) {
    New-Item -Path $monitorPath -Force | Out-Null
}
Set-ItemProperty -Path $monitorPath -Name "DpiValue" -Type DWord -Value 4

# Dark-Mode!
# Unfortunately, I don't know yet how to activate the dark mode of Edge
Set-ItemProperty -Path "HKCU:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize" -Name AppsUseLightTheme -Value 0

# hosts:
$hostsFile = @"
10.0.2.2 vagrant-host
"@
Set-Content -Path "$env:windir\System32\drivers\etc\hosts" -Value $hostsFile -Force

# System locale
Set-WinSystemLocale -SystemLocale de-DE

# Region
# https://docs.microsoft.com/windows/win32/intl/table-of-geographical-locations
# Set-WinHomeLocation -GeoId 0xF4 # USA
Set-WinHomeLocation -GeoId 0x5e # Germany

# Regional format
Set-Culture -CultureInfo de-DE

# To get the list of time zones: Get-TimeZone -ListAvailable
# Or here: https://support.microsoft.com/en-us/help/973627/microsoft-time-zone-index-values
Set-TimeZone -Id "W. Europe Standard Time"

# Language and Keyboard (default is the first)
# https://docs.microsoft.com/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs
# en-US: 0x0409; de-DE: 0x0407
$languages = "de-DE", "en-US"
# https://docs.microsoft.com/windows-hardware/manufacture/desktop/windows-language-pack-default-values
# English (International): 0x00020409; English (US): 0x00000409; German: 0x00000407
$keyboards = 0x407, 0x20409

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
