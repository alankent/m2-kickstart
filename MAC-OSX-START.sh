#!/bin/sh

CONTAINER=m2-luma

docker run -d -p 5000:5000 -p 22:22 -p 80:80 -p 3000:3000 -p 3001:3001 --name m2-luma alankent/${CONTAINER}

echo Extracting binaries from container to make sure we have compatible version.
docker cp ${CONTAINER}:/mac-osx/Contents/MacOS/Unison .

# TODO: SYNC ~/.composer DIRECTORY TO PRIME THE CACHE IN THE CONTAINER?
# TODO: PUSH . TO CONTAINER, TO MAKE SURE ANY LOCAL CUSTOMIZATIONS WIN?


echo '*************************************************************************'
echo '**** PLEASE BE PATIENT: This can take a few minutes on first startup ****'
echo '*************************************************************************'

# Give container a chance to start up so Unison can connect.
sleep 5

echo Starting Unison bi-directional file synchronization process.
./Unison . socket://localhost:5000//magento2 -auto -repeat watch -batch \
    -ignore "Path .devsync.yml" \
    -ignore "Path Dockerfile" \
    -ignore "Path Vagrantfile" \
    -ignore "Path .vagrant" \
    -ignore "Path .git" \
    -ignore "Path .gitignore" \
    -ignore "Path .gitattributes" \
    -ignore "Path var/cache" \
    -ignore "Path var/composer_home" \
    -ignore "Path var/log" \
    -ignore "Path var/page_cache" \
    -ignore "Path var/session" \
    -ignore "Path var/tmp" \
    -ignore "Path pub/media" \
    -ignore "Path pub/static" \
    -ignore "Path .idea" \
    -ignore "Path app/etc/env.php" \
    -ignore "Path .magento" \
    -ignore "Path template" \
    -ignore "Path Unison" \
    -ignore "Path WINDOWS-START.BAT" \
    -ignore "Path WINDOWS-STOP.BAT" \
    -ignore "Path WINDOWS-SHELL.BAT" \
    -ignore "Path MAC-OSX-START.sh" \
    -ignore "Path MAC-OSX-STOP.sh" \
    -ignore "Path MAC-OSX-SHELL.sh" \
    -ignore "Name {.*.swp}"

