# Get-KasperskyDbAge.ps1
# Возвращает информацию о файлах баз Kaspersky и их возрасте в днях

$basePaths = @(
    "C:\ProgramData\Kaspersky Lab",
    "C:\Program Files\Kaspersky Lab",
    "C:\Program Files (x86)\Kaspersky Lab"
)

$results = @()

foreach ($basePath in $basePaths) {
    if (Test-Path $basePath) {
        $files = Get-ChildItem -Path $basePath -Recurse -Include "*.kdc","*.dat" -ErrorAction SilentlyContinue |
            Where-Object { $_.DirectoryName -like "*Bases*" -or $_.DirectoryName -like "*bases*" } |
            Sort-Object LastWriteTime -Descending |
            Select-Object -First 3

        foreach ($file in $files) {
            $ageDays = [math]::Round(((Get-Date) - $file.LastWriteTime).TotalDays, 1)
            $results += [PSCustomObject]@{
                FullName = $file.FullName
                LastWriteTime = $file.LastWriteTime.ToString("yyyy-MM-dd HH:mm:ss")
                AgeDays = $ageDays
            }
        }
    }
}

if ($results.Count -gt 0) {
    $results | ConvertTo-Json -Depth 3
} else {
    Write-Output "NO_KASPERSKY_BASES_FOUND"
}
