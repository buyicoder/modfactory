@echo off
echo ========================================
echo  Setup: minecraft-ai texture generator
echo ========================================
echo.

cd /d "%~dp0"

if not exist "minecraft-ai" (
    echo [1/3] Cloning minecraft-ai...
    git clone https://github.com/Jhon-crypt/minecraft-ai.git
    if %errorlevel% neq 0 (
        echo [FAIL] Could not clone. Install git or download manually.
        pause
        exit /b 1
    )
) else (
    echo [1/3] minecraft-ai already exists
)

echo [2/3] Installing Python dependencies...
pip install torch torchvision pillow numpy
if %errorlevel% neq 0 (
    echo [WARN] pip install failed. Try: pip install torch torchvision pillow numpy
)

echo [3/3] Verifying setup...
python -c "from src.minecraft_ai_generator.texture_generator import generate_texture; print('minecraft-ai ready!')" 2>nul
if %errorlevel% neq 0 (
    echo [WARN] Import test failed — check torch installation
) else (
    echo [OK] minecraft-ai is ready!
)

echo.
echo ========================================
echo  Setup complete!
echo.
echo  Usage: python -c "from src.minecraft_ai_generator.texture_generator import generate_texture; generate_texture('your prompt here')"
echo ========================================
pause
