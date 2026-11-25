@echo off
rem Windows launcher for the lab tool: finds Git for Windows' bash and runs ./lab.
rem Works from cmd and PowerShell (.\lab.cmd). Never uses System32\bash.exe (that is WSL).
setlocal
set "LAB_BASH="
for %%P in ("%ProgramFiles%\Git\bin\bash.exe" "%ProgramFiles(x86)%\Git\bin\bash.exe" "%LocalAppData%\Programs\Git\bin\bash.exe") do (
  if not defined LAB_BASH if exist "%%~P" set "LAB_BASH=%%~P"
)
for %%K in (HKLM HKCU) do (
  if not defined LAB_BASH (
    for /f "tokens=2,*" %%A in ('reg query "%%K\SOFTWARE\GitForWindows" /v InstallPath 2^>nul ^| find "InstallPath"') do (
      if exist "%%B\bin\bash.exe" set "LAB_BASH=%%B\bin\bash.exe"
    )
  )
)
if not defined LAB_BASH (
  for /f "delims=" %%G in ('where git.exe 2^>nul') do (
    if not defined LAB_BASH if exist "%%~dpG..\bin\bash.exe" set "LAB_BASH=%%~dpG..\bin\bash.exe"
    if not defined LAB_BASH if exist "%%~dpG..\..\bin\bash.exe" set "LAB_BASH=%%~dpG..\..\bin\bash.exe"
  )
)
if not defined LAB_BASH (
  echo lab: couldn't find Git for Windows' bash.exe. Install Git for Windows: https://git-scm.com/download/win
  exit /b 2
)
set "LAB_KIT=%~dp0"
set "LAB_KIT=%LAB_KIT:\=/%"
"%LAB_BASH%" "%LAB_KIT%lab" %*
exit /b %ERRORLEVEL%
