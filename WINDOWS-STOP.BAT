if not defined SYNC_PROJECT set SYNC_PROJECT=m2-blank

docker kill %SYNC_PROJECT%
docker rm %SYNC_PROJECT%

pause
