ECHO OFF
COLOR 9b
CLS
ECHO Casio Radio Update Tool by: Willster419
ECHO By using the script you understand that this is done at YOUR own risk.
ECHO Make sure you have drivers installed and usb debugging mode enabled!
pause
cls
ECHO #Updating your radio...
adb wait-for-device
rem verifies root by calling the help command to see if the su binary is installed
for /f %%i in ('adb shell su -h') do set var12=%%i
if "%var12%"=="su:" (
GOTO NR
)
ECHO #preparing for update...
if exist backupRecovery.img (
del backupRecovery.img
)
rem backup the old recovery
for /f %%i in ('adb shell busybox') do set var10=%%i
if "%var10%"=="busybox:" (
GOTO NBB
)
adb shell su -c "busybox mount -o remount,rw /system"
adb push tools\mkyaffs2image /sdcard/mkyaffs2image
adb push tools\onandroid /sdcard/onandroid
adb shell su -c "busybox cp /sdcard/mkyaffs2image /system/bin/mkyaffs2image"
adb shell su -c "busybox cp /sdcard/onandroid /system/bin/onandroid"
adb shell su -c "rm /sdcard/onandroid"
adb shell su -c "rm /sdcard/mkyaffs2image"
adb shell su -c "chmod 755 /system/bin/mkyaffs2image"
adb shell su -c "chmod 755 /system/bin/onandroid"
ECHO #Loading ONandroid script...
adb shell sleep 1
adb shell su -c "onandroid -c casioRootPlus -a recovery"
adb pull /mnt/sdcard/clockworkmod/backup/casioRootPlus/recovery.img backupRecovery.img
adb shell rm /mnt/sdcard/clockworkmod/backup/casioRootPlus/recovery.img >nul
adb shell su -c "rm -r /mnt/sdcard/clockworkmod/backup/casioRootPlus"
ECHO #Backup Complete!
rem flash the GNM recovery
adb wait-for-device
adb reboot bootloader
fastboot -i 0x0409 flash recovery recoveryImage/GNM.img
fastboot -i 0x0409 reboot
rem copy the radio update files over to the device and set it to install it
ECHO Waiting for a full boot to lock screen...
adb wait-for-device
adb shell sleep 5
:checkLoopRadio
adb shell sleep 1
for /f %%i in ('adb shell "getprop init.svc.bootanim"') do set var4=%%i
if "running"=="%var4%" (
goto checkLoopRadio
)
adb shell sleep 10
adb shell "rm /mnt/sdcard/update.zip" > nul
adb push radioUpdate\m150RadioUpdate.zip /sdcard/update.zip
adb shell su -c "echo '--update_package=SDCARD:update.zip' >> /cache/recovery/command"
ECHO #device is ready! Rebooting...
adb reboot recovery
ECHO #waiting for recovery...
rem wait for recovery to install the update zip
ping 1.1.1.1 -n 1 -w 15000 > nul
ECHO #flashing...
ECHO #Wait untill the update is complete to continue
pause
rem remove the zip and but the original recovery back on it
adb shell rm /sdcard/update.zip
adb shell "reboot bootloader"
fastboot -i 0x0409 flash recovery backupRecovery.img
fastboot -i 0x0409 reboot
adb wait-for-device
if exist backupRecovery.img (
del backupRecovery.img
)
ECHO #Install Complete!
pause
GOTO MENU

:NR
ECHO #Error: Your phone is not rooted. In order to continue
ECHO #with the requested operation, you need to root your
ECHO #phone first.
ping 1.1.1.1 -n 1 -w 7000 > nul
GOTO MENU

:NBB
ECHO #Error: Your phone does not have busybox installed. In order to continue
ECHO #with the requested operation, you need to install busybox.
ping 1.1.1.1 -n 1 -w 7000 > nul
GOTO MENU
