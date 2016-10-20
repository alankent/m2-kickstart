
if not defined SYNC_PROJECT set SYNC_PROJECT=m2-blank

SETLOCAL

@rem Start up a Docker container, then sync files between local file system
@rem and the container.


@set SYNC_CONTAINER=alankent/m2-blank
@set SYNC_HTTP_PORT=80
@set SYNC_BROWSERSYNC_PORT=3000
@set SYNC_BROWSERSYNCADMIN_PORT=3001
@set SYNC_UNISON_PORT=5000
@set SYNC_SSH_PORT=22

docker run -d -p 80:%SYNC_HTTP_PORT% -p 3000:%SYNC_BROWSERSYNC_PORT% -p 3001:%SYNC_BROWSERSYNCADMIN_PORT% -p 5000:%SYNC_UNISON_PORT% -p 22:%SYNC_SSH_PORT% --name %SYNC_PROJECT% %SYNC_CONTAINER%

rem Extracting binaries from container to make sure we have compatible version.
docker cp %SYNC_PROJECT%:/windows/unison.exe .
docker cp %SYNC_PROJECT%:/windows/unison-fsmonitor.exe .

@set IGNORE=

@rem Magento files not worth pulling locally.
@set IGNORE=%IGNORE% -ignore "Path var/cache"
@set IGNORE=%IGNORE% -ignore "Path var/composer_home"
@set IGNORE=%IGNORE% -ignore "Path var/log"
@set IGNORE=%IGNORE% -ignore "Path var/page_cache"
@set IGNORE=%IGNORE% -ignore "Path var/session"
@set IGNORE=%IGNORE% -ignore "Path var/tmp"
@set IGNORE=%IGNORE% -ignore "Path pub/media"
@set IGNORE=%IGNORE% -ignore "Path pub/static"
@set IGNORE=%IGNORE% -ignore "Path app/etc/env.php"

@rem Other files not worth pushing to the container.
@set IGNORE=%IGNORE% -ignore "Path WINDOWS-START.BAT"
@set IGNORE=%IGNORE% -ignore "Path WINDOWS-STOP.BAT"
@set IGNORE=%IGNORE% -ignore "Path WINDOWS-SHELL.BAT"
@set IGNORE=%IGNORE% -ignore "Path Dockerfile"
@set IGNORE=%IGNORE% -ignore "Path Vagrantfile"
@set IGNORE=%IGNORE% -ignore "Path .vagrant"
@set IGNORE=%IGNORE% -ignore "Path .git"
@set IGNORE=%IGNORE% -ignore "Path .gitignore"
@set IGNORE=%IGNORE% -ignore "Path .gitattributes"
@set IGNORE=%IGNORE% -ignore "Path .magento"
@set IGNORE=%IGNORE% -ignore "Path .idea"
@set IGNORE=%IGNORE% -ignore "Name {.*.swp}"
@set IGNORE=%IGNORE% -ignore "Name {.unison.*}"

@set LOCAL_ROOT=.
@set REMOTE_ROOT=socket://localhost:%SYNC_UNISON_PORT%//magento2 

@set UNISONARGS=%LOCAL_ROOT% %REMOTE_ROOT% -prefer %LOCAL_ROOT% -preferpartial "Path var -> %REMOTE_ROOT%" -auto -batch %IGNORE%

rem *************************************************************************
rem **** PLEASE BE PATIENT: This can take a few minutes on first startup ****
rem *************************************************************************

rem Give container a chance to start up so Unison can connect.
set loopcount=100
:loop
    rem Is Unison ready in container yet?
    .\unison %LOCAL_ROOT% %REMOTE_ROOT% -batch -auto -testserver
    if NOT ERRORLEVEL 1 goto exitloop
    timeout 2
    @set /a loopcount=loopcount-1
    @if %loopcount%==0 goto exitloop
    @goto loop
:exitloop

rem **** Pulling files from container (faster quiet mode) ****
.\unison %UNISONARGS% -silent >NUL:

rem **** Entering file watch mode ****
.\unison %UNISONARGS% -repeat watch

pause
