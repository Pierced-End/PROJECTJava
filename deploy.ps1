# Simple Sudoku Solver Deployment for New PC
Write-Host "🎯 Sudoku Solver Deployment" -ForegroundColor Green
Write-Host ""

# Find where the WAR file is
$warFile = "$PSScriptRoot\sudoku.war"
if (-not (Test-Path $warFile)) {
    $warFile = Read-Host "Enter full path to sudoku.war"
}

if (-not (Test-Path $warFile)) {
    Write-Host "❌ WAR file not found!" -ForegroundColor Red
    pause
    exit
}

Write-Host "✅ WAR file: $warFile ($((Get-Item $warFile).Length) bytes)" -ForegroundColor Green

# Find Tomcat
Write-Host "`n🔍 Looking for Tomcat..." -ForegroundColor Yellow
$tomcatDir = $null
@(
    "C:\xampp\tomcat",
    "C:\apache-tomcat-9.0.89",
    "C:\Program Files\Apache Software Foundation\Tomcat 9.0"
) | ForEach-Object {
    if ((Test-Path "$_\webapps") -and (-not $tomcatDir)) {
        $tomcatDir = $_
    }
}

if (-not $tomcatDir) {
    Write-Host "Tomcat not found in common locations." -ForegroundColor Yellow
    $tomcatDir = Read-Host "Enter your Tomcat installation path (e.g., C:\xampp\tomcat)"
}

if (-not (Test-Path "$tomcatDir\webapps")) {
    Write-Host "❌ Invalid Tomcat directory!" -ForegroundColor Red
    pause
    exit
}

Write-Host "✅ Tomcat: $tomcatDir" -ForegroundColor Green

# Stop Tomcat
Write-Host "`n⏹️  Stopping Tomcat..." -ForegroundColor Yellow
cmd /c "$tomcatDir\bin\shutdown.bat" 2>$null
Start-Sleep -Seconds 5

# Clean old deployment
Write-Host "🧹 Cleaning old deployment..." -ForegroundColor Yellow
Remove-Item "$tomcatDir\webapps\sudoku" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$tomcatDir\webapps\sudoku.war" -Force -ErrorAction SilentlyContinue
Remove-Item "$tomcatDir\work\Catalina\localhost\sudoku" -Recurse -Force -ErrorAction SilentlyContinue

# Deploy
Write-Host "📦 Deploying..." -ForegroundColor Yellow
Copy-Item $warFile -Destination "$tomcatDir\webapps\sudoku.war" -Force

# Start Tomcat
Write-Host "🚀 Starting Tomcat..." -ForegroundColor Yellow
cmd /c "$tomcatDir\bin\startup.bat"

Write-Host "⏳ Waiting for deployment..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Open browser
Write-Host "🌐 Opening Sudoku Solver..." -ForegroundColor Cyan
Start-Process "http://localhost:8080/sudoku"

Write-Host ""
Write-Host "✅ Done! If the app doesn't load, wait 10 more seconds and refresh." -ForegroundColor Green
Write-Host ""
pause