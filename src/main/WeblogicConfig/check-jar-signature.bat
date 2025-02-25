@echo off
setlocal

set JAR_DIR=C:\Oracle\Middleware\Oracle_Home\user_projects\domains\base_domain\app\my_App
set KEYSTORE=D:\Learning\TestSignProject\src\main\resources\mykeystore1.jks
set STOREPASS=adminadmin1

echo Verifying the signature of all WAR files in the directory: %JAR_DIR%

for %%F in (%JAR_DIR%\*.war %JAR_DIR%\*.jar) do (
    echo Checking signature for %%F...
    
    jarsigner -verify -verbose -keystore %KEYSTORE% -storepass %STOREPASS% %%F > temp.txt 2>&1
       
    findstr /c:"jar verified." temp.txt > nul
    if ERRORLEVEL 1 (
        echo ERROR: The file '%%F' has not signature! Deployment is not allowed.
		exit /b 1
    ) else (
        echo The file '%%F' has a signature.
    )
	
	findstr /c:"MYKEY1" temp.txt > nul
    if ERRORLEVEL 1 (
        echo ERROR: The file '%%F' is signed with an unknown certificate! Deployment is not allowed.
        exit /b 1
    ) else (
        echo The file '%%F' has a valid signature from a trusted source.
    )

    del temp.txt
)

echo All WAR files have valid signatures. Deployment is allowed.
exit /b 0