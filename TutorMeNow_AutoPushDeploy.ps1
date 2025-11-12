# ============================
# TutorMeNow_AutoPushDeploy.ps1
# ============================
Write-Host "=== 🚀 Starting TutorMeNow AutoPush + Deploy ===" -ForegroundColor Cyan

$projectPath = "C:\Users\William\Documents\TutorMeNow"
$deployHook = "https://api.render.com/deploy/srv-d3opd39r0fns73dof2og?key=Mu5rsNZDa84"

Set-Location $projectPath

# --- STEP 1: Commit and Push ---
try {
    git add .
    git commit -m "Auto-push from PowerShell $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ErrorAction SilentlyContinue
    git push origin main
    Write-Host "✅ Git repository synced successfully." -ForegroundColor Green
} catch {
    Write-Host "❌ Git push failed: $($_.Exception.Message)" -ForegroundColor Red
}

# --- STEP 2: Trigger Render Deploy ---
try {
    Write-Host "🚀 Sending deploy request to Render..." -ForegroundColor Cyan
    $response = Invoke-WebRequest -Uri $deployHook -Method POST -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Host "✅ Render deployment triggered successfully!" -ForegroundColor Green
    } else {
        Write-Host "⚠️ Render responded with code $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Render deploy failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "=== ✅ TutorMeNow AutoPush + Deploy Finished ===" -ForegroundColor Cyan
