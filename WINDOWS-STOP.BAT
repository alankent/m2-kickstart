call WINDOWS-SETTINGS.BAT

docker kill %SYNC_PROJECT%
docker rm %SYNC_PROJECT%

pause
