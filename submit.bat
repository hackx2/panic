@echo off
setlocal

call :cleanup
mkdir release || goto :error

for %%F in (LICENSE haxelib.json readme.md .gitattributes .gitignore extraParams.hxml) do (
    echo %%F
    if exist "%%F" (
        copy /y "%%F" release\ >nul || goto :error
    ) else (
        echo %%F not found... skipping
    )
)

xcopy src release\src /E /I /Y >nul || goto :error
if exist docs xcopy docs release\docs /E /I /Y >nul

pushd release
tar -a -c -f ..\release.zip * || (popd & goto :error)
popd

haxelib submit release.zip || goto :error

call :cleanup
echo ~ finished ^<3
pause
exit /b 0

:error
call :cleanup
echo.
echo ~ failed
pause
exit /b 1

:cleanup
echo ~ cleanup
if exist release.zip del /q release.zip
if exist release rmdir /s /q release
exit /b 0
