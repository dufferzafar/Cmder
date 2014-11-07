@echo off
setlocal

set MSECT=1
set MPATH=F:\Powerpack\Cmder\manpages

if "%1" == "" (
  echo Usage: gh [section] name
  goto end
)

if "%1" == "-d" (
  shift
  goto git
)

if not "%2" == "" (
  set MSECT=%1
  shift
)

set MFILE=%MPATH%\man%MSECT%\git-%1.%MSECT%

if not exist %MFILE% (
  echo No git man page found for %1 - %MFILE%
  echo Now starting git help %1 ...
  echo.
  goto git
)

@set PATH=%PATH%;F:\Powerpack\Cmder\vendor\groff\bin;

groff -Tascii -pet -mandoc -P-c %MFILE% | less -irs
goto end

:git
git help %1

:end
endlocal
