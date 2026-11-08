@echo off
chcp 65001 > nul
echo =====================================================================
echo  ASSET RIPPER PORT - CÔNG CỤ TRÍCH XUẤT SOURCE GAME TỪ THƯ MỤC APK
echo =====================================================================
echo.

python "%~dp0tools\assetripper_port.py" %*

echo.
pause
