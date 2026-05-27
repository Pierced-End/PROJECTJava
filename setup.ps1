# Sudoku Solver Setup Script for New PC
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Sudoku Solver - New PC Setup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get current directory (where this script is)
$projectDir = $PSScriptRoot
if (-not $projectDir) {
    $projectDir = Get-Location
}

Write-Host "📁 Project directory: $projectDir" -ForegroundColor Yellow

# Step 1: Find Java
Write-Host "`n[1/5] Finding Java JDK..." -ForegroundColor Yellow

$javacPath = $null
$possiblePaths = @(
    "C:\Program Files\Java\jdk*\bin\javac.exe",
    "C:\Program Files (x86)\Java\jdk*\bin\javac.exe",
    "$env:JAVA_HOME\bin\javac.exe"
)

foreach ($pattern in $possiblePaths) {
    $found = Get-ChildItem $pattern -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($found) {
        $javacPath = $found.FullName
        break
    }
}

if (-not $javacPath) {
    Write-Host "❌ Java JDK not found!" -ForegroundColor Red
    Write-Host "Please install JDK 11+ from: https://adoptium.net/" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "After installing, run this script again." -ForegroundColor Yellow
    pause
    exit 1
}

$jdkBin = Split-Path $javacPath -Parent
Write-Host "✅ Found JDK: $jdkBin" -ForegroundColor Green

# Step 2: Check project structure
Write-Host "`n[2/5] Checking project files..." -ForegroundColor Yellow

$requiredFiles = @(
    "$projectDir\src\com\sudoku\SudokuServlet.java",
    "$projectDir\src\com\sudoku\SudokuGenerator.java",
    "$projectDir\src\com\sudoku\DancingLinksSolver.java",
    "$projectDir\web\index.html",
    "$projectDir\web\css\style.css",
    "$projectDir\web\WEB-INF\web.xml"
)

$allFilesPresent = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ $($file.Replace($projectDir, ''))" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $($file.Replace($projectDir, '')) MISSING!" -ForegroundColor Red
        $allFilesPresent = $false
    }
}

if (-not $allFilesPresent) {
    Write-Host "`n❌ Some files are missing! Make sure you copied the entire project." -ForegroundColor Red
    pause
    exit 1
}

# Step 3: Download libraries if missing
Write-Host "`n[3/5] Checking libraries..." -ForegroundColor Yellow

$libDir = "$projectDir\lib"
if (-not (Test-Path $libDir)) {
    New-Item -ItemType Directory -Force -Path $libDir | Out-Null
}

if (-not (Test-Path "$libDir\servlet-api.jar")) {
    Write-Host "Downloading servlet-api.jar..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://repo1.maven.org/maven2/javax/servlet/javax.servlet-api/4.0.1/javax.servlet-api-4.0.1.jar" -OutFile "$libDir\servlet-api.jar"
}

if (-not (Test-Path "$libDir\gson.jar")) {
    Write-Host "Downloading gson.jar..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "https://repo1.maven.org/maven2/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar" -OutFile "$libDir\gson.jar"
}

# Copy gson to web lib
$webLibDir = "$projectDir\web\WEB-INF\lib"
if (-not (Test-Path $webLibDir)) {
    New-Item -ItemType Directory -Force -Path $webLibDir | Out-Null
}
Copy-Item "$libDir\gson.jar" -Destination "$webLibDir\gson.jar" -Force

Write-Host "✅ Libraries ready" -ForegroundColor Green

# Step 4: Compile
Write-Host "`n[4/5] Compiling Java files..." -ForegroundColor Yellow

$classpath = "$libDir\servlet-api.jar;$libDir\gson.jar"
$srcFiles = "$projectDir\src\com\sudoku\*.java"
$outDir = "$projectDir\web\WEB-INF\classes"

if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Force -Path $outDir | Out-Null
}

$compileCmd = "& '$javacPath' -cp '$classpath' -d '$outDir' '$srcFiles'"
Invoke-Expression $compileCmd

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compilation successful!" -ForegroundColor Green
} else {
    Write-Host "❌ Compilation failed!" -ForegroundColor Red
    pause
    exit 1
}

# Step 5: Deploy to Tomcat
Write-Host "`n[5/5] Deploying to Tomcat..." -ForegroundColor Yellow

# Find Tomcat
$tomcatDir = $null
$searchPaths = @(
    "C:\xampp\tomcat",
    "C:\apache-tomcat-9.0.89",
    "C:\Program Files\Apache Software Foundation\Tomcat 9.0"
)

foreach ($path in $searchPaths) {
    if (Test-Path "$path\webapps") {
        $tomcatDir = $path
        break
    }
}

if (-not $tomcatDir) {
    Write-Host "⚠️  Tomcat not found in common locations." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Where is your Tomcat installed?" -ForegroundColor Cyan
    Write-Host "Examples:" -ForegroundColor White
    Write-Host "  C:\\xampp\\tomcat" -ForegroundColor White
    Write-Host "  C:\\apache-tomcat-9.0.89" -ForegroundColor White
    Write-Host ""
    $tomcatDir = Read-Host "Enter Tomcat path"
    
    if (-not (Test-Path "$tomcatDir\webapps")) {
        Write-Host "❌ Invalid Tomcat path! webapps folder not found." -ForegroundColor Red
        pause
        exit 1
    }
}

Write-Host "✅ Tomcat found: $tomcatDir" -ForegroundColor Green

# Stop Tomcat
Write-Host "Stopping Tomcat..." -ForegroundColor Yellow
cmd /c "$tomcatDir\bin\shutdown.bat" 2>$null
Start-Sleep -Seconds 3

# Clean and deploy
Write-Host "Deploying application..." -ForegroundColor Yellow
$webappsDir = "$tomcatDir\webapps"
Remove-Item "$webappsDir\sudoku" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "$webappsDir\sudoku.war" -Force -ErrorAction SilentlyContinue

# Copy web folder to Tomcat
Copy-Item "$projectDir\web\*" -Destination "$webappsDir\sudoku" -Recurse -Force

# Start Tomcat
Write-Host "Starting Tomcat..." -ForegroundColor Yellow
cmd /c "$tomcatDir\bin\startup.bat"

Write-Host "`n⏳ Waiting for server to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Open browser
Write-Host "🌐 Opening Sudoku Solver..." -ForegroundColor Cyan
Start-Process "http://localhost:8080/sudoku"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  SETUP COMPLETE!" -ForegroundColor Green
Write-Host "  URL: http://localhost:8080/sudoku" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "To stop the server:" -ForegroundColor Yellow
Write-Host "  $tomcatDir\bin\shutdown.bat" -ForegroundColor White
Write-Host ""
pause