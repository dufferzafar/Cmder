:: Init Script for cmd.exe
:: Sets some nice defaults
:: Created as part of cmder project

:: Used by the rest of the script
@set rootDir="%~dp0\.."

:: Change the prompt style
:: Mmm tasty lamb
@prompt $E[1;32;40m$P$S{git}$S$_$E[1;30;40m{lamb}$S$E[0m

:: Pick right version of clink
@if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set architecture=86
) else (
    set architecture=64
)

:: Run clink
@%rootDir%\vendor\clink\clink_x%architecture%.exe inject --quiet --profile %rootDir%\config

:: Prepare for msysgit
:: Even I don't know, copy-pasted from their .bat
@set PLINK_PROTOCOL=ssh
@set git_install_root=%rootDir%\vendor\msysgit
@if not defined TERM set TERM=msys

:: Used by "git"
@set PATH=%PATH%;%git_install_root%\bin;%git_install_root%\cmd;

:: Add Binary Utilities
@set PATH=%PATH%;%rootDir%\bin;%rootDir%\vendor\utils;

:: GNU Utils
@set PATH=%PATH%;%rootDir%\vendor\gow\bin;%rootDir%\vendor\UnxUtils\usr\local\wbin;

:: Add Moar 3rd Party Stuff
@set PATH=%PATH%;%rootDir%\vendor\vim\vim74;%rootDir%\vendor\google

:: Python 3.3
@set PATH=%PATH%;C:\Python33\Scripts;

:: Add aliases
:: These little thingies are life savers, believe me.
@doskey /macrofile="%rootDir%\config\aliases"

:: Set home path
@set HOME=%USERPROFILE%

:: Environment settings required by 'cheat'
@set EDITOR=F:\PowerPack\Cmder\vendor\vim\vim74\vim.exe
@set DEFAULT_CHEAT_DIR=F:\Powerpack\Cmder\cheats
@set CHEATCOLORS=true

:: Oh, the hacks I make
:: This one here is for 't - the commandline twitter client'
:: https://github.com/sferik/t/issues/107
@set SSL_CERT_FILE=C:\Ruby193\cacert.pem

:: The offical Github application fucks up 'credential.helper'
:: But I do like to use that app once in a while to view logs and stuff.
:: So, we just restore the settings everytime.
@copy "D:\Github\.gitconfig" "C:\Users\dufferzafar\.gitconfig" /Y 1>nul

:: Feel free to modify/remove
@echo [3;1mWelcome to cmder! customized by [31;mdufferzafar
