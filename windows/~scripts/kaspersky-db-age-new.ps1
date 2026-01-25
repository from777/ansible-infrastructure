$avList = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct -ErrorAction SilentlyContinue | Where-Object { $_.displayName -like '*Kaspersky*' }
if ($avList) {
    $maxDate = $null
    foreach ($av in $avList) {
        if ($av.timestamp) {
            $ts = [DateTime]::ParseExact($av.timestamp, 'ddd, dd MMM yyyy HH:mm:ss GMT', [System.Globalization.CultureInfo]::InvariantCulture)
            if ($maxDate -eq $null -or $ts -gt $maxDate) { $maxDate = $ts }
        }
    }
    if ($maxDate) {
        $days = [math]::Round(((Get-Date) - $maxDate).TotalDays, 1)
        $days.ToString([System.Globalization.CultureInfo]::InvariantCulture)
    } else { -1 }
} else { -1 }
