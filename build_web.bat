@echo off
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║          Building QuantumMind RTLS - Web Version         ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.
echo 🔨 Building web app...
echo This may take a few minutes...
echo.
flutter build web --release

if %errorlevel% equ 0 (
    echo.
    echo ✅ Build successful!
    echo.
    echo Output: build\web\
    echo.
    echo You can deploy these files to any web server:
    echo - GitHub Pages
    echo - Netlify
    echo - Vercel
    echo - Firebase Hosting
    echo.
) else (
    echo.
    echo ❌ Build failed!
    echo Check the errors above.
    echo.
)
pause
