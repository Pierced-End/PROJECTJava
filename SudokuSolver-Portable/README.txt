SUDOKU SOLVER - PORTABLE PACKAGE
================================

Requirements on new PC:
- Java JDK 11 or higher (https://adoptium.net/)
- Windows OS

Setup Instructions:
1. Copy this entire folder to the new PC
2. Double-click "setup.bat"
3. Wait for Tomcat to download (if needed) and start
4. Browser will open automatically to http://localhost:8080/sudoku

If you already have XAMPP or Tomcat installed:
- Just copy "sudoku-app" folder to your Tomcat's "webapps" folder as "sudoku"
- Or copy "sudoku.war" to your Tomcat's "webapps" folder
- Start/Restart Tomcat
- Open http://localhost:8080/sudoku

To stop the application:
- Run: {TOMCAT_DIR}\bin\shutdown.bat
- Or use XAMPP Control Panel

Files included:
- sudoku-app/     : Complete web application (already compiled)
- sudoku.war      : WAR file for deployment
- setup.bat       : Automatic setup script