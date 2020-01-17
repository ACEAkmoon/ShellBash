@ECHO OFF

echo $$__$$__$$$$$___$$______$$_______$$$$
echo $$__$$__$$______$$______$$______$$__$$
echo $$$$$$__$$$$____$$______$$______$$__$$
echo $$__$$__$$______$$______$$______$$__$$
echo $$__$$__$$$$$___$$$$$$__$$$$$$___$$$$
echo.
echo $$___$$_$$__$$
echo $$$_$$$__$$$$
echo $$_$_$$___$$
echo $$___$$___$$
echo $$___$$___$$
echo.
echo $$$$$$__$$$$$___$$$$$$__$$$$$___$$__$$__$$$$$
echo $$______$$__$$____$$____$$______$$$_$$__$$__$$
echo $$$$____$$$$$_____$$____$$$$____$$_$$$__$$__$$
echo $$______$$__$$____$$____$$______$$__$$__$$__$$
echo $$______$$__$$__$$$$$$__$$$$$___$$__$$__$$$$$
echo.
echo //////////////////////////////////////////////////////////////////////////////
echo We won't take much of your time, up to 5 minutes
echo.
echo Please note that your computer will be unavailable for 3-5 minutes
echo When completed, hang-ups and unavailability of response may occur... ;(
echo Don't worry all right. The pre-process process is coming to an end! :D
echo.
echo //////////////////////////////////////////////////////////////////////////////
echo Please wait for the script to finish, it will notify you of the completion !!!
echo //////////////////////////////////////////////////////////////////////////////
echo.

FOR /f "tokens=2" %%i in ('netsh interface ip show ipaddress 5') do @(set IP_ADDRES=%%i & goto function)
:function
SET IP_ADDRES=%IP_ADDRES: =%

SET	/P NUM="Enter num-PC - "
SET	/P HALL="Enter hall - "
echo :
echo Enter num-PC is - %NUM%
echo Enter hall is - %HALL%
echo IP addres WiFi is %IP_ADDRES%
pause
SET NAME="%NUM%.%USERNAME%_%COMPUTERNAME%-IP%IP_ADDRES%"
SET PATH_AUDIT=\\192.168.88.231\rev.01_arm\hall_%HALL%\%NAME%.txt
SET PATH_AIDA=\\192.168.88.231\rev.01_arm\aida64business620\
SET PATH_AIDA_EXE=%PATH_AIDA%aida64.exe
SET PAHT_AIDA_RPF=%PATH_AIDA%aida64.rpf

if not exist %PATH_AUDIT% ( %PATH_AIDA_EXE% /R %PATH_AUDIT% /TEXT /CUSTOM %PAHT_AIDA_RPF% ) else exit

echo.
echo Well Done.
pause
