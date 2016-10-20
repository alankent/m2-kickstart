
@rem Start up a Docker container, then sync files between local file system
@rem and the container.


@set CONTAINER=m2-luma

docker run -d -p 5000:5000 -p 22:22 -p 80:80 -p 3000:3000 -p 3001:3001 --name m2-luma alankent/%CONTAINER%

rem Extracting binaries from container to make sure we have compatible version.
docker cp %CONTAINER%:/windows/unison.exe .
docker cp %CONTAINER%:/windows/unison-fsmonitor.exe .

@REM TODO: SYNC ~/.composer DIRECTORY TO PRIME THE CACHE IN THE CONTAINER?
@REM TODO: PUSH src TO CONTAINER FIRST TO MAKE SURE LOCAL CUSTOMIZATIONS WIN?

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

@rem Other files not worth pushing to the site
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

@set UNISONARGS=src socket://localhost:5000//magento2 -auto -batch %IGNORE%

rem *************************************************************************
rem **** PLEASE BE PATIENT: This can take a few minutes on first startup ****
rem *************************************************************************

rem Give container a chance to start up so Unison can connect.
timeout 5

rem **** Performing an initial sync (faster quiet mode) ****
.\unison %UNISONARGS% -silent >NUL:

rem **** Entering file watch mode ****
.\unison %UNISONARGS% -repeat watch

pause
