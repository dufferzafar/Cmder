@echo off
SET CMDER_ROOT=%~dp0

:: Pick right version of clink
@if "%PROCESSOR_ARCHITECTURE%"=="x86" (
    set architecture=86
) else (
    set architecture=64
)

start %~dp0/vendor/conemu/ConEmu%architecture%.exe /Icon "%CMDER_ROOT%\icons\cmder.ico" /Title Cmder /LoadCfgFile "%CMDER_ROOT%\config\ConEmu.xml"
