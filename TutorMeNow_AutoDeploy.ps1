# ===============================================
# TutorMeNow_AutoDeploy.ps1
# Automatic GitHub Push + Render Deployment + Browser Open
# ===============================================

# --- CONFIG ---
$repoURL = "https://github.com/1wbillingsley-App/TutorMeNow_App.git"
$renderHook = "https://api.render.com/deploy/srv-d3opd39r0fns73dof2og?key=h58hVauSeDY"
$renderLiveURL = "https://tutormenowapp.onrender.com"  # replace with your Render live site URL
$projectPath = "$env:USERPROFILE\Documents\TutorMeNow"
$commitMessage = "TutorMeNow auto-deploy $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# --- GOTO PROJECT FOLDER ---
Set-Location $projectPath
Write-Host "📂 Working in: $projectPath" -ForegroundColor Yellow

# --- GIT SETUP ---
git init | Out-Null
git remote remove origin 2>$null
git remote add origin $repoURL
git branch -M main

# --- CHECK FOR CHANGES ---
Write-Host "🟢 Checking for changes..." -ForegroundColor Green
git add -A
$changes = git status --porcelain

if ($changes) {
    git commit -m $commitMessage
    Write-Host "✅ Changes committed." -ForegroundColor Cyan
} else {
    Write-Host "⚪ No new changes to commit." -ForegroundColor DarkGray
}

# --- PUSH TO GITHUB ---
Write-Host "📤 Pushing updates to GitHub..." -ForegroundColor Yellow
git push -u origin main -f
Write-Host "✅ GitHub push complete." -ForegroundColor Green

# --- TRIGGER RENDER DEPLOY ---
Write-Host "🚀 Triggering Render Deploy..." -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $renderHook -Method POST | Out-Null
    Write-Host "🎉 Render deploy triggered successfully!" -ForegroundColor Magenta
} catch {
    Write-Host "❌ Render deploy failed. Check key or network." -ForegroundColor Red
}

# --- WAIT THEN OPEN LIVE SITE ---
Start-Sleep -Seconds 10
Write-Host "🌐 Opening live Render site..." -ForegroundColor Yellow
Start-Process $renderLiveURL

Write-Host "✨ DONE — TutorMeNow is live and refreshed!" -ForegroundColor Cyan
