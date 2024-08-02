@echo off
echo ---------gen all config-----------
for /R %%f in (*.xls) do (
echo %%f.......................
..\release\main.exe -skipscript "%%f"
)

::set source_dir=D:\work\server\service\game\script
::set dest_dir=Z:\server_project\server\service\game\script

::xcopy %source_dir% %dest_dir% /S/Y
::echo hello world
pause
