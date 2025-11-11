# ==============================
# TutorMeNow Render API Deployer
# ==============================

Write-Host "`n=== TutorMeNow Direct Render Deployment ===`n" -ForegroundColor Cyan

# --- SETTINGS ---
$renderApiKey = "rnd_GTYyFbbazJykpNdD3f4poXsX5TFd"
$serviceId    = "srv-d3opd39r0fns73dof2og"
$branch       = "main"
$logFile      = "$PSScriptRoot\RenderDeploy_Log.txt"

# --- PREPARE REQUEST ---
$headers = @{
    "Authorization" = "Bearer $renderApiKey"
    "Content-Type"  = "application/json"
}
$body = @{ branch = $branch } | ConvertTo-Json
$apiUrl = "https://api.render.com/v1/services/$serviceId/deploys"

# --- DEPLOY ---
Write-Host "🚀 Sending deploy request for branch '$branch'..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $apiUrl -Method POST -Headers $headers -Body $body -ErrorAction Stop
    if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 201) {
        Write-Host "✅ Render deployment triggered successfully!" -ForegroundColor Green
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content $logFile "[$timestamp] SUCCESS: Deployment triggered for branch '$branch'"
    }
    else {
        Write-Host "⚠️ Render responded with code: $($response.StatusCode)" -ForegroundColor Yellow
        Write-Host $response.Content
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Add-Content $logFile "[$timestamp] WARNING: Render responded with code $($response.StatusCode)"
    }
}
catch {
    Write-Host "❌ Deployment failed: $($_.Exception.Message)" -ForegroundColor Red
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content $logFile "[$timestamp] ERROR: $($_.Exception.Message)"
}

Write-Host "`n=== Deployment Script Finished ===`n" -ForegroundColor Cyan
