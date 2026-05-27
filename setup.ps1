$projectDir = "$HOME\Desktop\sudoku-solver"
$jdkBin = "C:\Program Files\Java\jdk-*\bin"

Write-Host "🔍 Finding JDK..." -ForegroundColor Yellow
$javac = Get-ChildItem "C:\Program Files\Java\jdk*\bin\javac.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $javac) {
    Write-Host "❌ JDK not found! Install from: https://adoptium.net/" -ForegroundColor Red
    exit
}
$jdkBin = $javac.DirectoryName
Write-Host "✅ JDK: $jdkBin" -ForegroundColor Green

# Download libraries if missing
if (-not (Test-Path "$projectDir\lib\gson.jar")) {
    Write-Host "📥 Downloading libraries..." -ForegroundColor Yellow
    Invoke-WebRequest "https://repo1.maven.org/maven2/com/google/code/gson/gson/2.10.1/gson-2.10.1.jar" -OutFile "$projectDir\lib\gson.jar"
    Invoke-WebRequest "https://repo1.maven.org/maven2/javax/servlet/javax.servlet-api/4.0.1/javax.servlet-api-4.0.1.jar" -OutFile "$projectDir\lib\servlet-api.jar"
    Copy-Item "$projectDir\lib\gson.jar" -Destination "$projectDir\web\WEB-INF\lib\gson.jar" -Force
}

# Compile
Write-Host "🔨 Compiling..." -ForegroundColor Yellow
& "$jdkBin\javac" -cp "$projectDir\lib\servlet-api.jar;$projectDir\lib\gson.jar" -d "$projectDir\web\WEB-INF\classes" "$projectDir\src\com\sudoku\*.java"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Compiled!" -ForegroundColor Green
    
    # Find Tomcat
    $tomcat = @("C:\xampp\tomcat", "C:\apache-tomcat-*") | ForEach-Object {
        Get-ChildItem $_ -Directory -ErrorAction SilentlyContinue | Select-Object -First 1
    } | Select-Object -First 1
    
    if ($tomcat) {
        Write-Host "📦 Deploying to $($tomcat.FullName)..." -ForegroundColor Yellow
        Remove-Item "$($tomcat.FullName)\webapps\sudoku*" -Recurse -Force -ErrorAction SilentlyContinue
        Copy-Item "$projectDir\web\*" -Destination "$($tomcat.FullName)\webapps\sudoku" -Recurse -Force
        cmd /c "$($tomcat.FullName)\bin\shutdown.bat" 2>$null
        Start-Sleep 3
        cmd /c "$($tomcat.FullName)\bin\startup.bat"
        Start-Sleep 10
        Start-Process "http://localhost:8080/sudoku"
    } else {
        Write-Host "⚠️  Tomcat not found. Install XAMPP or Tomcat first." -ForegroundColor Yellow
    }
}