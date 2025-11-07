Write-Host ""
Write-Host "🚀 AutoSmartFinder Starting..." -ForegroundColor Cyan

# === Build folder list ===
$folders = @("$env:USERPROFILE\Documents", "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Downloads")
$drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Name -ne "C" }
foreach ($d in $drives) { $folders += "$($d.Root)" }

# === Create Results File ===
$resultFile = "$env:USERPROFILE\Desktop\AutoSmartFinder_Results.txt"
if (Test-Path $resultFile) { Remove-Item $resultFile -Force }

# === Begin Scan ===
$allFiles = @()
Write-Host ""
Write-Host "🔎 Scanning folders..." -ForegroundColor Yellow
$totalFolders = $folders.Count
$folderIndex = 0

foreach ($folder in $folders) {
    $folderIndex++
    Write-Progress -Activity "Scanning locations..." -Status "Scanning $folder ($folderIndex of $totalFolders)" -PercentComplete (($folderIndex / $totalFolders) * 100)
    try {
        $found = Get-ChildItem -Path $folder -Recurse -ErrorAction SilentlyContinue
        $allFiles += $found
    } catch {
        Write-Host "⚠️ Skipped: $folder (access denied)" -ForegroundColor DarkYellow
    }
}

Write-Progress -Activity "Scanning locations..." -Completed
$total = $allFiles.Count
Write-Host "📂 Files found: $total" -ForegroundColor Cyan
Write-Host ""

# === Progress through files ===
$count = 0
$collected = @()

foreach ($file in $allFiles) {
    $count++
    if ($count % 100 -eq 0) {
        $percent = [int](($count / $total) * 100)
        Write-Progress -Activity "Processing files..." -Status "$percent% Complete ($count / $total)" -PercentComplete $percent
    }

    $collected += [PSCustomObject]@{
        Name = $file.Name
        Path = $file.FullName
        SizeKB = [Math]::Round(($file.Length / 1KB), 2)
        Modified = $file.LastWriteTime
    }
}

Write-Progress -Activity "Processing files..." -Completed

# === Save Results ===
$collected | Sort-Object Modified -Descending | Out-File -FilePath $resultFile -Encoding UTF8
Write-Host ""
Write-Host "✅ Scan Complete!" -ForegroundColor Green
Write-Host "📁 Results saved to: $resultFile" -ForegroundColor Green
Write-Host ""

# === Auto Log for recordkeeping ===
$logFile = "$env:USERPROFILE\Documents\TutorMeNow\logs\AutoSmartFinder_Log_$(Get-Date -Format yyyyMMdd_HHmmss).txt"
Copy-Item -Path $resultFile -Destination $logFile -Force

Write-Host "🪵 Log archived at: $logFile" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏳ This program will auto-run every 24 hours." -ForegroundColor Yellow
Start-Sleep -Seconds 5
