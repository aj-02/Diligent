@echo off
REM Windows wrapper so sync.sh runs from cmd.exe or PowerShell, not just Git Bash.
REM Usage:  scripts\sync.cmd                    commit + pull + push
REM         scripts\sync.cmd "ZMB5B qty fix"    with your own commit message
REM         scripts\sync.cmd --pull-only        just bring the repo up to date
setlocal
set "SH=%ProgramFiles%\Git\bin\bash.exe"
if not exist "%SH%" set "SH=%ProgramFiles(x86)%\Git\bin\bash.exe"
if not exist "%SH%" set "SH=bash.exe"
"%SH%" "%~dp0sync.sh" %*
