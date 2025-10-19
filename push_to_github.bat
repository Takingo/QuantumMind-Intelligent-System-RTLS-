@echo off
chcp 65001 >nul
echo.
echo ╔═══════════════════════════════════════════════════════════╗
echo ║        QuantumMind RTLS - Push to GitHub                 ║
echo ╚═══════════════════════════════════════════════════════════╝
echo.

REM Check if git is installed
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Git is not installed!
    echo.
    echo Please install Git from: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

echo ✅ Git found
echo.

REM Check if already a git repo
if exist ".git" (
    echo ℹ️  Git repository already initialized
) else (
    echo [1/5] Initializing Git repository...
    git init
    if %errorlevel% neq 0 (
        echo ❌ Failed to initialize git
        pause
        exit /b 1
    )
    echo ✅ Git initialized
)

echo.
echo [2/5] Configuring Git user (if needed)...
git config user.name >nul 2>&1
if %errorlevel% neq 0 (
    set /p username="Enter your GitHub username: "
    git config user.name "%username%"
)
git config user.email >nul 2>&1
if %errorlevel% neq 0 (
    set /p email="Enter your GitHub email: "
    git config user.email "%email%"
)

echo.
echo [3/5] Adding all files...
git add .
if %errorlevel% neq 0 (
    echo ❌ Failed to add files
    pause
    exit /b 1
)
echo ✅ Files staged

echo.
echo [4/5] Creating initial commit...
git commit -m "Initial commit: QuantumMind RTLS Flutter Application - UWB-based intelligent automation with real-time tracking dashboard"
if %errorlevel% neq 0 (
    echo ⚠️  Commit warning (might be empty or already committed)
)

echo.
echo [5/5] Adding remote and pushing to GitHub...
echo.

REM Check if remote exists
git remote get-url origin >nul 2>&1
if %errorlevel% neq 0 (
    echo Adding remote origin...
    git remote add origin https://github.com/Takingo/QuantumMind-Intelligent-System-RTLS-.git
) else (
    echo Remote already exists, updating...
    git remote set-url origin https://github.com/Takingo/QuantumMind-Intelligent-System-RTLS-.git
)

echo.
echo Setting main branch...
git branch -M main

echo.
echo Pushing to GitHub...
echo You may be asked for GitHub credentials...
echo.
git push -u origin main

if %errorlevel% equ 0 (
    echo.
    echo ╔═══════════════════════════════════════════════════════════╗
    echo ║              ✅ Successfully Pushed to GitHub!            ║
    echo ╚═══════════════════════════════════════════════════════════╝
    echo.
    echo 🌐 Your repository:
    echo    https://github.com/Takingo/QuantumMind-Intelligent-System-RTLS-
    echo.
    echo 📝 Next steps:
    echo    - Add a description on GitHub
    echo    - Set repository visibility (public/private)
    echo    - Add collaborators if needed
    echo.
) else (
    echo.
    echo ❌ Push failed!
    echo.
    echo Common issues:
    echo  - Repository doesn't exist on GitHub (create it first)
    echo  - Wrong credentials
    echo  - No permission to push
    echo.
    echo Try:
    echo  1. Go to https://github.com/Takingo/QuantumMind-Intelligent-System-RTLS-
    echo  2. Make sure repository exists
    echo  3. Check your GitHub access token/credentials
    echo.
)

echo.
pause
