@echo off
for /f "delims=" %%A in ('git ls-remote --get-url origin') do set "git_url=%%A"

echo Opening repo on Github - %git_url%

start %git_url%
