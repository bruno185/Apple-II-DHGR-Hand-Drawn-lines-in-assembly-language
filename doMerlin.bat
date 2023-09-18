@echo off
if %errorlevel% neq 0 exit /b %errorlevel%
echo --------------- Variables ---------------
rem name of program. Change it to your own program name
Set PRG=asmdemo
rem current folder
Set ProjectFolder=.

Set MyAppleFolder=F:\Bruno\Dev\AppleWin
Set APPLEWIN=%MyAppleFolder%\AppleWin\Applewin.exe
Set MERLIN32ROOT=%MyAppleFolder%\Merlin32_v1.0
Set MERLIN32LIBS=%MERLIN32ROOT%\Library
Set MERLIN32WIN=%MERLIN32ROOT%\Windows
Set MERLIN32EXE=%MERLIN32WIN%\merlin32.exe
rem Set MERLIN32EXE=%MERLIN32WIN%\merlin32 1.1.10.exe
Set APPLECOMMANDER=%MyAppleFolder%\Utilitaires\AppleCommander-win64-1.6.0.jar
rem Set ACJAR=java.exe -jar %APPLECOMMANDER%    ; avec ""
Set ACJAR=java.exe -jar %APPLECOMMANDER%
rem echo %ACJAR%

echo --------------- debut Merlin ---------------
%MERLIN32EXE% -V %MERLIN32LIBS% %ProjectFolder%\%PRG%.s
if exist %ProjectFolder%\error_output.txt exit
echo --------------- fin Merlin ---------------

rem copy /Y %ProjectFolder%\A.po %ProjectFolder%\%PRG%.po
copy /Y %ProjectFolder%\A.po %ProjectFolder%\%PRG%.po

echo --------------- Debut Applecommander ---------------
rem add binary program to image disk
rem 16384 = $4000. Change it to your own ORG address.
rem %ACJAR% -d %PRG%
rem %ACJAR% -p %PRG%.po %PRG% bin 24576 < %PRG%
%ACJAR% -p %PRG%.po %PRG% bin 2048 < %PRG%
echo --------------- fin Applecommander ---------------

echo --------------- Debut Applewin ---------------
%APPLEWIN% -d1 %PRG%.po
rem %APPLEWIN% -h1 %PRG%.po
echo --------------- Fin Applewin ---------------
