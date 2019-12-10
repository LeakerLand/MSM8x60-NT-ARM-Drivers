@echo off

REM Second boot drivers
\Windows\OEM\devcon.exe update \Windows\OEM\Drivers\ChargeArbitration.inf Root\CAD

call :installRootDevice fusionv2.inf umdf2\FusionV2 ROOT\FusionV2\0000

REM MBB
powershell -command "[System.Environment]::OSVersion.Version.Build" > psout.txt
set /p osbuild=<psout.txt
del psout.txt

if %osbuild% gtr 18908 (
    \Windows\OEM\devcon.exe update \Windows\OEM\Drivers\WA\qcmbb.wa8960.inf ACPI\QCOM2072
) else (
    \Windows\OEM\devcon.exe update \Windows\OEM\Drivers\WP\qcmbb.wp8960.inf ACPI\QCOM2072
)

cmd.exe /c \Windows\OEM\IHVDriversOobe.cmd

\Windows\OEM\devcon.exe status @ACPI\QCOM2072\*1 | findstr "43" > nul
if %errorlevel%==0 (
    \Windows\OEM\devcon.exe remove @ACPI\QCOM2072\*1
    \Windows\OEM\devcon.exe dp_add \Windows\OEM\Drivers\qcmbbnull.inf
    \Windows\OEM\devcon.exe rescan
)

\Windows\OEM\devcon.exe status @ACPI\QCOM2072\*0 | findstr "43" > nul
if %errorlevel%==0 (
    \Windows\OEM\devcon.exe remove @ACPI\QCOM2072\*0
    \Windows\OEM\devcon.exe dp_add \Windows\OEM\Drivers\qcmbbnull.inf
    \Windows\OEM\devcon.exe rescan
)

goto :eof

REM 
REM Arguments:
REM 
REM 1: Driver Inf filename in driver store's file repository
REM 2: Driver Inf hardware id
REM 3: Root driver hardware id
REM 
:installRootDevice 
for /f "delims=*" %%f in ('dir /b /s \Windows\System32\DriverStore\FileRepository\%1') do \Windows\OEM\devcon.exe install %%f %3
\Windows\OEM\devcon.exe sethwid @%3 := +%2
for /f "delims=*" %%f in ('dir /b /s \Windows\System32\DriverStore\FileRepository\%1') do \Windows\OEM\devcon.exe update %%f %3
goto :eof