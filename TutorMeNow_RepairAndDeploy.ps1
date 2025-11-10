# ==============================================
# TutorMeNow_AutoFixDeploy.ps1
# Self-Repair + Auto-Deploy for Render
# ==============================================

Write-Host "`n🩵 Starting TutorMeNow Repair + Deploy..." -ForegroundColor Cyan

# --- Config ---
$deployScript = "$env:USERPROFILE\Documents\TutorMeNow\TutorMeNow_AutoDeploy.ps1"
$backupScript = "$deployScript.bak"
$correctHook = "https://api.render.com/deploy/srv-d3opd39r0fns73dof2og?key=h58hVauSeDY"
$correctLive = "https://tutormenowapp.onrender.com"

# --- Verify Script Exists ---
if (-not (Test-Path $deployScript)) {
    Write-Host "❌ Cannot find $deployScript" -ForegroundColor Red
    exit
}

# --- Backup ---
Copy-Item $deployScript $backupScript -Force
Write-Host "✅ Backup created: $backupScript" -ForegroundColor Gray

# --- Read + Repair ---
$content = Get-Content $deployScript -Raw
$repaired = $content

# Fix possible missing equal sign or typo in renderHook
$repaired = $repaired -replace '(?m)\$renderHook\s*=\s*".*"', "`$renderHook = `"$correctHook`""
$repaired = $repaired -replace '(?m)\$renderLiveURL\s*=\s*".*"', "`$renderLiveURL = `"$correctLive`""

if ($repaired -ne $content) {
    Set-Content -Path $deployScript -Value $repaired -Encoding UTF8 -Force
    Write-Host "🔧 Fixed incorrect Render URLs inside the deploy script." -ForegroundColor Yellow
} else {
    Write-Host "✅ URLs already correct, no changes made." -ForegroundColor Green
}

# --- Confirm ---
Write-Host "`n🔍 Checking URLs in script..." -ForegroundColor Cyan
Get-Content $deployScript | Select-String "render" | ForEach-Object {
    Write-Host "   $_" -ForegroundColor Gray
}

# --- Deploy ---
Write-Host "`n🚀 Triggering Render Deploy..." -ForegroundColor Cyan
$maxRetries = 3
$retryDelay = 10
$success = $false

for ($i = 1; $i -le $maxRetries; $i++) {
    try {
        $response = Invoke-WebRequest -Uri $correctHook -Method POST -UseBasicParsing -TimeoutSec 30
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ Render responded with HTTP 200 OK — deploy triggered successfully!" -ForegroundColor Green
            $success = $true
            break
        } else {
            Write-Host "⚠️ Render responded with HTTP $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Attempt $i failed: $($_.Exception.Message)" -ForegroundColor Red
        if ($i -lt $maxRetries) {
            Write-Host "⏳ Retrying in $retryDelay seconds..." -ForegroundColor Yellow
            Start-Sleep -Seconds $retryDelay
        }
    }
}

# --- Results ---
if ($success) {
    Write-Host "`n🎉 Deployment request sent successfully!" -ForegroundColor Green
    Start-Sleep -Seconds 10
    Start-Process $correctLive
    Write-Host "🌍 TutorMeNow is live and refreshed!" -ForegroundColor Magenta
} else {
    Write-Host "`n💀 Render deploy failed after $maxRetries attempts. Check if this URL works in your browser:" -ForegroundColor Red
    Write-Host "   $correctHook" -ForegroundColor Yellow
}

Write-Host "`n🕒 Script completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
