@ECHO OFF

@REM WARNING: This file is created by the Configuration Wizard.
@REM Any changes to this script may be lost when adding extensions to this configuration.

SETLOCAL

@REM --- Start Functions ---

GOTO :ENDFUNCTIONS

:stopAll
	@REM We separate the stop commands into a function so we are able to use the trap command in Unix (calling a function) to stop these services
	if NOT "X%ALREADY_STOPPED%"=="X" (
		exit /b
	)
	@REM STOP DERBY (only if we started it)
	if "%DERBY_FLAG%"=="true" (
		echo Stopping Derby server...
		call "%WL_HOME%\common\derby\bin\stopNetworkServer.cmd"  >"%DOMAIN_HOME%\derbyShutdown.log" 2>&1 

		echo Derby server stopped.
	)

	set ALREADY_STOPPED=true
GOTO :EOF

:generateClassList
	set JAVA_OPTIONS=%JAVA_OPTIONS% -Xshare:off -XX:+UnlockCommercialFeatures -XX:+IgnoreEmptyClassPaths -XX:DumpLoadedClassList=%APPCDS_CLASS_LIST% -XX:+UseAppCDS
GOTO :EOF

:useArchive
	set JAVA_OPTIONS=%JAVA_OPTIONS% -XX:+UnlockCommercialFeatures -Xshare:auto -XX:+UseAppCDS -XX:+IgnoreEmptyClassPaths -XX:SharedArchiveFile=%APPCDS_ARCHIVE% -showversion
	set USING_SHOWVERSION=true
GOTO :EOF

:restoreOrigEnv
	@REM Restore environment variables to their original values, before they were appended
	set PATH=%INITIAL_PATH%
	set CLASSPATH=%INITIAL_CLASSPATH%
	set WEBLOGIC_CLASSPATH=%INITIAL_WEBLOGIC_CLASSPATH%
	set PRE_CLASSPATH=%INITIAL_PRE_CLASSPATH%
	set POST_CLASSPATH=%INITIAL_POST_CLASSPATH%
	set JAVA_OPTIONS=%INITIAL_JAVA_OPTIONS%
GOTO :EOF


:ENDFUNCTIONS

@REM --- End Functions ---

@REM *************************************************************************
@REM This script is used to start WebLogic Server for this domain.
@REM 
@REM To create your own start script for your domain, you can initialize the
@REM environment by calling @USERDOMAINHOME\setDomainEnv.
@REM 
@REM setDomainEnv initializes or calls commEnv to initialize the following variables:
@REM 
@REM BEA_HOME       - The BEA home directory of your WebLogic installation.
@REM JAVA_HOME      - Location of the version of Java used to start WebLogic
@REM                  Server.
@REM JAVA_VENDOR    - Vendor of the JVM (i.e. BEA, HP, IBM, Sun, etc.)
@REM PATH           - JDK and WebLogic directories are added to system path.
@REM WEBLOGIC_CLASSPATH
@REM                - Classpath needed to start WebLogic Server.
@REM PATCH_CLASSPATH - Classpath used for patches
@REM PATCH_LIBPATH  - Library path used for patches
@REM PATCH_PATH     - Path used for patches
@REM WEBLOGIC_EXTENSION_DIRS - Extension dirs for WebLogic classpath patch
@REM JAVA_VM        - The java arg specifying the VM to run.  (i.e.
@REM                - server, -hotspot, etc.)
@REM USER_MEM_ARGS  - The variable to override the standard memory arguments
@REM                  passed to java.
@REM PRODUCTION_MODE - The variable that determines whether Weblogic Server is started in production mode.
@REM DERBY_HOME - Derby home directory.
@REM DERBY_CLASSPATH
@REM                - Classpath needed to start Derby.
@REM 
@REM Other variables used in this script include:
@REM SERVER_NAME    - Name of the weblogic server.
@REM JAVA_OPTIONS   - Java command-line options for running the server. (These
@REM                  will be tagged on to the end of the JAVA_VM and
@REM                  MEM_ARGS)
@REM PROXY_SETTINGS - These are tagged on to the end of the JAVA_OPTIONS. This variable is deprecated and should not
@REM                  be used. Instead use JAVA_OPTIONS
@REM 
@REM For additional information, refer to "Administering Server Startup and Shutdown for Oracle WebLogic Server"
@REM *************************************************************************

set SCRIPTPATH=%~dp0
set SCRIPTPATH=%SCRIPTPATH%
for %%i in ("%SCRIPTPATH%") do set SCRIPTPATH=%%~fsi

@REM Store original environment variables before appending, in case of restart

set INITIAL_PATH=%PATH%
set INITIAL_CLASSPATH=%CLASSPATH%
set INITIAL_PRE_CLASSPATH=%PRE_CLASSPATH%
set INITIAL_POST_CLASSPATH=%POST_CLASSPATH%
set INITIAL_WEBLOGIC_CLASSPATH=%WEBLOGIC_CLASSPATH%
set INITIAL_JAVA_OPTIONS=%JAVA_OPTIONS%

@REM Call setDomainEnv here.

set DOMAIN_HOME=C:\Oracle\Middleware\Oracle_Home\user_projects\domains\base_domain
for %%i in ("%DOMAIN_HOME%") do set DOMAIN_HOME=%%~fsi

call "%DOMAIN_HOME%\bin\setDomainEnv.cmd" %*

set SAVE_JAVA_OPTIONS=%JAVA_OPTIONS%
set SAVE_CLASSPATH=%CLASSPATH%
set TMP_UPDATE_SCRIPT=%TMP%\update.cmd

@REM Start Derby

set DERBY_DEBUG_LEVEL=0

if "%DERBY_FLAG%"=="true" (
	call "%WL_HOME%\common\derby\bin\startNetworkServer.cmd"  >"%DOMAIN_HOME%\derby.log" 2>&1 
)

set JAVA_OPTIONS=%SAVE_JAVA_OPTIONS%

set #JAVA_OPTIONS=-XX:+IgnoreUnrecognizedVMOptions -XX:+UnlockCommercialFeatures -XX:+ResourceManagement -XX:+UseG1GC %SAVE_JAVA_OPTIONS%

set SAVE_JAVA_OPTIONS=
set CLASSPATH=%SAVE_CLASSPATH%

if "%PRODUCTION_MODE%"=="true" (
	set WLS_DISPLAY_MODE=Production
) else (
	set WLS_DISPLAY_MODE=Development
)

if NOT "%WLS_USER%"=="" (
	set JAVA_OPTIONS=%JAVA_OPTIONS% -Dweblogic.management.username=%WLS_USER%
)

if NOT "%WLS_PW%"=="" (
	set JAVA_OPTIONS=%JAVA_OPTIONS% -Dweblogic.management.password=%WLS_PW%
)

if NOT "%MEDREC_WEBLOGIC_CLASSPATH%"=="" (
	if NOT "%CLASSPATH%"=="" (
		set CLASSPATH=%CLASSPATH%;%MEDREC_WEBLOGIC_CLASSPATH%
	) else (
		set CLASSPATH=%MEDREC_WEBLOGIC_CLASSPATH%
	)
)

if "%GENERATE_CLASS_LIST%"=="true" (
	CALL :generateClassList
)

if "%USE_ARCHIVE%"=="true" (
	CALL :useArchive
)

echo .

echo JAVA Memory arguments: %MEM_ARGS%
echo .
echo CLASSPATH=%CLASSPATH%
echo .
echo PATH=%PATH%
echo .
echo ***************************************************
echo *  To start WebLogic Server, use a username and   *
echo *  password assigned to an admin-level user.  For *
echo *  server administration, use the WebLogic Server *
echo *  console at http:\\hostname:port\console        *
echo ***************************************************
ECHO ------------------------------------
if exist %CHECK_JAR_SIGNATURE% (
    echo Checking JAR Signatures...
    call %CHECK_JAR_SIGNATURE%
    
    if ERRORLEVEL 1 (
        echo ERROR: Unsigned or invalid JAR file detected! WebLogic will not start.
        exit /b 1
    ) else (
        echo JAR signature verification completed successfully. Proceeding with WebLogic startup.
    )
) else (
    echo ERROR: JAR signature check script not found at %CHECK_JAR_SIGNATURE%!
    exit /b 1
)
ECHO -------------------------------
@REM START WEBLOGIC

if NOT "%USE_JVM_SYSTEM_LOADER%"=="true" (
	set LAUNCH_ARGS=-cp %WL_HOME%\server\lib\weblogic-launcher.jar -Dlaunch.use.env.classpath=true
)

if "%USING_SHOWVERSION%"=="true" (
	echo starting weblogic with Java version:
	%JAVA_HOME%\bin\java %JAVA_VM% -version
)

if "%WLS_REDIRECT_LOG%"=="" (
	echo Starting WLS with line:
	echo %JAVA_HOME%\bin\java %JAVA_VM% %MEM_ARGS% %LAUNCH_ARGS% -Dweblogic.Name=%SERVER_NAME% -Djava.security.policy=%WLS_POLICY_FILE% %JAVA_OPTIONS% %PROXY_SETTINGS% %SERVER_CLASS%
	%JAVA_HOME%\bin\java %JAVA_VM% %MEM_ARGS% %LAUNCH_ARGS% -Dweblogic.Name=%SERVER_NAME% -Djava.security.policy=%WLS_POLICY_FILE% %JAVA_OPTIONS% %PROXY_SETTINGS% %SERVER_CLASS%
) else (
	echo Redirecting output from WLS window to %WLS_REDIRECT_LOG%
	%JAVA_HOME%\bin\java %JAVA_VM% %MEM_ARGS% %LAUNCH_ARGS% -Dweblogic.Name=%SERVER_NAME% -Djava.security.policy=%WLS_POLICY_FILE% %JAVA_OPTIONS% %PROXY_SETTINGS% %SERVER_CLASS%  >"%WLS_REDIRECT_LOG%" 2>&1 
)

IF ERRORLEVEL 86 IF NOT ERRORLEVEL 87 (set shutDownStatus=86) ELSE (IF ERRORLEVEL 88 IF NOT ERRORLEVEL 89 ( set shutDownStatus=88 ) )

CALL :stopAll

popd

IF EXIST %TMP_UPDATE_SCRIPT% (set fileExists=true) ELSE (set fileExists=false)

if "%shutDownStatus%"=="86" (
	if "%fileExists%"=="true" (
		echo Calling %TMP_UPDATE_SCRIPT%
		cd %TMP:~0,2%
		cd %TMP%
		call %TMP_UPDATE_SCRIPT%
		IF ERRORLEVEL 42 IF NOT ERRORLEVEL 43 (set ustatus=42 )
		if "%ustatus%"=="42" (
			set JAVA_HOME=
		)
	) else (
		echo ERROR! %TMP_UPDATE_SCRIPT% did not exist
	)
	@REM restoring the original env before unsetting JAVA_HOME
	CALL :restoreOrigEnv
	@REM Call the same script path that was supplied in order to restart ourselves
	call "%SCRIPTPATH%\startWebLogic.cmd"
) else (
	if "%shutDownStatus%"=="88" (
		CALL :restoreOrigEnv
		call "%SCRIPTPATH%\startWebLogic.cmd"
	)
)

@REM Exit this script only if we have been told to exit.
if "%doExitFlag%"=="true" (
	exit
)

ENDLOCAL
