@echo off
for /f "delims=" %%A in ('git rev-parse --abbrev-ref HEAD') do set "branch_name=%%A"

echo git push --set-upstream origin %branch_name%

git push --set-upstream origin %branch_name%
