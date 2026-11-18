@echo off
REM Wegpunkt-Optimierer starten (Windows)
REM -------------------------------------
REM Diese Datei liegt im Hauptordner des Projekts (neben index.html).
REM Doppelklick genuegt: startet automatisch einen lokalen Webserver in diesem
REM Ordner (noetig fuer den Modus "Echtes Wegenetz", der Internetzugriff braucht)
REM und oeffnet den Wegpunkt-Optimierer im Standardbrowser.
REM
REM Zum Beenden: das Server-Fenster schliessen, das sich zusaetzlich oeffnet.

cd /d "%~dp0"

set PORT=8000
:checkport
netstat -ano | findstr /R /C:":%PORT% .*LISTENING" >nul
if %errorlevel%==0 (
    set /a PORT+=1
    goto checkport
)

echo Ordner: %cd%
echo Starte lokalen Server auf Port %PORT% ...
echo.

where python >nul 2>nul
if %errorlevel%==0 (
    start "Wegpunkt-Optimierer Server" cmd /k python -m http.server %PORT%
) else (
    where py >nul 2>nul
    if %errorlevel%==0 (
        start "Wegpunkt-Optimierer Server" cmd /k py -m http.server %PORT%
    ) else (
        echo Python wurde nicht gefunden. Bitte Python von https://www.python.org/downloads/ installieren
        echo ^(beim Installieren die Option "Add python.exe to PATH" ankreuzen^).
        pause
        exit /b 1
    )
)

timeout /t 1 /nobreak >nul
start "" "http://localhost:%PORT%/"

echo.
echo Server laeuft: http://localhost:%PORT%/
echo Das andere, gerade geoeffnete Server-Fenster offen lassen, solange du den Optimierer benutzt.
echo Dieses Fenster kannst du schliessen.
echo.
pause >nul
