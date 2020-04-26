# Should the automatic search and installation of updates be disabled?
$disableWindowsAutoUpdate = $true

# DPI-Scaling:
# 0 (100%, 96dpi); 1 (125%, 120dpi); 2 (150%, 144dpi); 3 (175%, 168dpi); 4 (200%, 192dpi)
$dpiScaling = 4

# Should the Dark Mode be activated?
$darkMode = $true

# hosts:
$hostsFile = @"
10.0.2.2 vagrant-host
"@

# To get the list of time zones: Get-TimeZone -ListAvailable
# Or here: https://support.microsoft.com/en-us/help/973627/microsoft-time-zone-index-values
$timeZone = "W. Europe Standard Time"

# Locale (for system locale an regional format)
$locale = "de-DE"

# Region
# https://docs.microsoft.com/windows/win32/intl/table-of-geographical-locations
# Germany: 0x5e, USA: 0xF4
$region = 0x5e

# List of languges (default is the first)
# https://docs.microsoft.com/windows-hardware/manufacture/desktop/default-input-locales-for-windows-language-packs
# en-US: 0x0409; de-DE: 0x0407
$languages = "de-DE", "en-US"

# List of keyboards
# https://docs.microsoft.com/windows-hardware/manufacture/desktop/windows-language-pack-default-values
# English (International): 0x00020409; English (US): 0x00000409; German: 0x00000407
$keyboards = 0x407