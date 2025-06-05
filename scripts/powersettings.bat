:: ========== Change Power Settings ==========

REM Set monitor timeout to 15 minutes (in seconds)
powercfg /change monitor-timeout-ac 15

REM Set sleep timeout to 15 minutes (in seconds)
powercfg /change standby-timeout-ac 15

REM For battery powered devices (optional)
powercfg /change monitor-timeout-dc 15
powercfg /change standby-timeout-dc 15

echo Power settings updated: monitors and sleep timeout set to 15 minutes.