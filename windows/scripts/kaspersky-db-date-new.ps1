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
        $maxDate.ToString('yyyy-MM-dd HH:mm')
    } else { 'N/A' }
} else { 'N/A' }
