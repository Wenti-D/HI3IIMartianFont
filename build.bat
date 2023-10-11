@echo off
cd /d %~dp0

set VENV_DIR=%~dp0fontmake_venv
set PYTHON=python

%PYTHON% -c "" >output.log 2>error.log
if %ERRORLEVEL% == 0 goto :check_pip
echo Couldn't launch python.
goto :show_output_error

:check_pip
%PYTHON% -m pip --help >output.log 2>error.log
if %ERRORLEVEL% == 0 goto :create_venv
echo Couldn't find pip.
goto :show_output_error

:create_venv
dir "%VENV_DIR%\Scripts\Python.exe" >output.log 2>error.log
if %ERRORLEVEL% == 0 goto :activate_venv

for /f "delims=" %%i in ('CALL python -c "import sys; print(sys.executable)"') do set PYTHON_FULLPATH="%%i"
echo Creating venv in %VENV_DIR% using python at %PYTHON_FULLPATH%.
%PYTHON% -m venv "%VENV_DIR%" >output.log 2>error.log
if %ERRORLEVEL% == 0 goto :activate_venv
echo Cannot create venv in "%VENV_DIR%".
goto :show_output_error

:activate_venv
set PYTHON="%VENV_DIR%\Scripts\Python.exe"
echo venv %VENV_DIR%.

:install_fontmake
echo Installing fontmake.
%PYTHON% -m pip install --upgrade pip >output.log 2>error.log
%PYTHON% -m pip install -r requirements.txt >output.log 2>error.log
if %ERRORLEVEL% == 0 goto :build_fonts
echo An error occured in installing requirements.
goto :show_output_error

:build_fonts
set OUTPUT_DIR=build_custom
set FONT_NAME=HI3IIMartian-Regular
echo Building fonts into %OUTPUT_DIR%.
fontmake -g %FONT_NAME%.glyphs --output-dir %OUTPUT_DIR% >output.log 2>error.log
%PYTHON% -c "from fontTools.ttLib.woff2 import compress; compress('%OUTPUT_DIR%/%FONT_NAME%.otf', '%OUTPUT_DIR%/%FONT_NAME%.woff2')" >output.log 2>error.log
if %ERRORLEVEL% == 0 goto :end_success

:show_output_error
echo.
echo Exit code: %ERRORLEVEL%.

for /f %%f in (output.log) do set size=%%~zf
if %size% equ 0 goto :show_error
echo.
echo output.log:
type output.log

:show_error
for /f %%f in (error.log) do set size=%%~zf
if %size% equ 0 goto :end
echo.
echo error.log:
type error.log

:end_success
echo.
echo Done.

:end
pause
exit /b %ERRORLEVEL%
