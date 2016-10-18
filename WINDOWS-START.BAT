
@rem Start up a Docker container, then sync files between local file system
@rem and the container.


@set CONTAINER=m2-luma

docker run -d -p 5000:5000 -p 22:22 -p 80:80 -p 3000:3000 -p 3001:3001 --name m2-luma alankent/%CONTAINER%

@echo Extracting binaries from container to make sure we have compatible version.
docker cp %CONTAINER%:/windows/unison.exe .
docker cp %CONTAINER%:/windows/unison-fsmonitor.exe .

@REM TODO: SYNC ~/.composer DIRECTORY TO PRIME THE CACHE IN THE CONTAINER?
@REM TODO: PUSH . TO CONTAINER, TO MAKE SURE ANY LOCAL CUSTOMIZATIONS WIN?

@set IGNORE=
@set IGNORE=%IGNORE% -ignore "Path Dockerfile"
@set IGNORE=%IGNORE% -ignore "Path Vagrantfile"
@set IGNORE=%IGNORE% -ignore "Path .vagrant"
@set IGNORE=%IGNORE% -ignore "Path .git"
@set IGNORE=%IGNORE% -ignore "Path .gitignore"
@set IGNORE=%IGNORE% -ignore "Path .gitattributes"
@set IGNORE=%IGNORE% -ignore "Path var/cache"
@set IGNORE=%IGNORE% -ignore "Path var/composer_home"
@set IGNORE=%IGNORE% -ignore "Path var/log"
@set IGNORE=%IGNORE% -ignore "Path var/page_cache"
@set IGNORE=%IGNORE% -ignore "Path var/session"
@set IGNORE=%IGNORE% -ignore "Path var/tmp"
@set IGNORE=%IGNORE% -ignore "Path pub/media"
@set IGNORE=%IGNORE% -ignore "Path pub/static"
@set IGNORE=%IGNORE% -ignore "Path .idea"
@set IGNORE=%IGNORE% -ignore "Path app/etc/env.php"
@set IGNORE=%IGNORE% -ignore "Path .magento"
@set IGNORE=%IGNORE% -ignore "Path template"
@set IGNORE=%IGNORE% -ignore "Path unison.exe"
@set IGNORE=%IGNORE% -ignore "Path unison-fsmonitor.exe"
@set IGNORE=%IGNORE% -ignore "Path WINDOWS-START.BAT"
@set IGNORE=%IGNORE% -ignore "Path WINDOWS-STOP.BAT"
@set IGNORE=%IGNORE% -ignore "Path WINDOWS-SHELL.BAT"
@set IGNORE=%IGNORE% -ignore "Path MAC-OSX-START.sh"
@set IGNORE=%IGNORE% -ignore "Path MAC-OSX-STOP.sh"
@set IGNORE=%IGNORE% -ignore "Path MAC-OSX-SHELL.sh"
@set IGNORE=%IGNORE% -ignore "Name {.*.swp}"
@set IGNORE=%IGNORE% -ignore "Name {.unison.*}"

@set UNISONARGS=. socket://localhost:5000//magento2 -auto -batch %IGNORE%

@echo *************************************************************************
@echo **** PLEASE BE PATIENT: This can take a few minutes on first startup ****
@echo *************************************************************************

@rem Give container a chance to start up so Unison can connect.
timeout 5

@rem Run first in silent mode so it does not list out EVERY filename on screen.
@echo **** Performing an initial sync (quiet mode) ****
.\unison %UNISONARGS% -silent >NUL:

@rem Then run in watch mode with more verbosity so you can see it working.
@echo **** Entering file watch mode ****
.\unison %UNISONARGS% -repeat watch

pause
