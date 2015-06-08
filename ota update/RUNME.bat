ECHO OFF
COLOR 9b
CLS
ECHO Casio Update Tool by: Willster419
ECHO By using the script you understand that this is done at YOUR own risk.
ECHO Make sure you have drivers installed and usb debugging mode enabled!
pause
cls
ECHO #This update requires root access
pause
ECHO #preparing for update...
ping 1.1.1.1 -n 1 -w 500 > nul
if exist backupRecovery.img (
del backupRecovery.img
)
rem verifies root by calling the help command to see if the su binary is installed
for /f %%i in ('adb shell su -h') do set var12=%%i
if "%var12%"=="su:" (
GOTO NR
)
rem get which update the user needs on his/her phone
ECHO #Getting your phone build version for update...
adb wait-for-device
ping 1.1.1.1 -n 1 -w 500 > nul
rem in each of these push which file is needed
for /f %%i in ('adb shell "getprop ro.build.id | cut -c 5-8"') do set var5=%%i
if "%var5%"=="M150"(
ECHO #Your phone build %var5% is already the latest build version. Congrats!
ping 1.1.1.1 -n 1 -w 3000 > nul
GOTO MENU
)
if "%var5%"=="M140"(
ECHO #Build %var5% Detected! Sending update...
adb push inopathUpdate\Casio_C771_M140ToM150.zip /sdcard/update.zip
ping 1.1.1.1 -n 1 -w 2000 > nul
GOTO updateSupported
)
if "%var5%"=="M130"(
ECHO #Build %var5% Detected! Sending update...
adb push inopathUpdate\Casio_C771_M130ToM140.zip /sdcard/update.zip
ping 1.1.1.1 -n 1 -w 2000 > nul
GOTO updateSupported
)
if "%var5%"=="M120"(
ECHO #Build %var5% Detected! Sending update...
adb push inopathUpdate\Casio_C771_M120ToM130.zip /sdcard/update.zip
ping 1.1.1.1 -n 1 -w 2000 > nul
GOTO updateSupported
)
if "%var5%"=="M110"(
ECHO #Build %var5% Detected! Sending update...
adb push inopathUpdate\Casio_C771_M110ToM120.zip /sdcard/update.zip
ping 1.1.1.1 -n 1 -w 2000 > nul
GOTO updateSupported
)
if "%var5%"=="M100"(
ECHO #Build %var5% Detected! Sending update...
adb push inopathUpdate\Casio_C771_M100ToM110.zip /sdcard/update.zip
ping 1.1.1.1 -n 1 -w 2000 > nul
GOTO updateSupported
)
if "%var5%"=="M80"(
ECHO #Build %var5% Detected! Sending update...
adb push inopathUpdate\Casio_C771_M080ToM100.zip /sdcard/update.zip
ping 1.1.1.1 -n 1 -w 2000 > nul
GOTO updateSupported
)
if "%var5%"=="M70"(
ECHO #Build %var5% Detected! Sending update...
adb push inopathUpdate\Casio_C771_M070ToM080.zip /sdcard/update.zip
ping 1.1.1.1 -n 1 -w 2000 > nul
GOTO updateSupported
)
if "%var5%"=="M50"(
ECHO #Build %var5% Detected! Sending update...
adb push inopathUpdate\Casio_C771_M050ToM070.zip /sdcard/update.zip
ping 1.1.1.1 -n 1 -w 2000 > nul
GOTO updateSupported
)
if "%var5%"=="M30"(
ECHO #Build %var5% Detected! Sending update...
adb push inopathUpdate\Casio_C771_M030ToM050.zip /sdcard/update.zip
ping 1.1.1.1 -n 1 -w 2000 > nul
GOTO updateSupported
)
ECHO #Error: your phone build version is not supported for update
ECHO #Contact willster419@outlook.com for details
ECHO #Have your build id ready for when you email
pause
GOTO MENU
:updateSupported
rem backup the current recovery
ECHO #Backing up the current recovery...
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
adb shell rm /mnt/sdcard/clockworkmod/backup/casioRootPlus/recovery.img > nul
adb shell su -c "rm -r /mnt/sdcard/clockworkmod/backup/casioRootPlus"
ECHO #Backup Complete!
rem flash GNM recovery
ECHO #flashing GNM recovery...
adb wait-for-device
adb reboot bootloader
fastboot -i 0x0409 flash recovery recoveryImage/GNM.img
fastboot -i 0x0409 reboot
ECHO #Success, waiting for full boot...
rem see echo
adb wait-for-device
adb shell sleep 5
:checkLoopInoUpdate
adb shell sleep 1
for /f %%i in ('adb shell "getprop init.svc.bootanim"') do set var4=%%i
if "running"=="%var4%" (
goto checkLoopInoUpdate
)
ECHO #Setting phone to update and rebooting...
adb shell su -c "echo '--update_package=SDCARD:update.zip' >> /cache/recovery/command"
rem adb shell su -c "ECHO #'--update_package=/sdcard/ipth_package.bin' >> /cache/recovery/command"
adb reboot recovery
rem wait for recovery to install the update
ping 1.1.1.1 -n 1 -w 15000 > nul
ECHO #flashing...
ECHO #Wait untill the update is complete to continue
pause
rem remove the update and but the original recovery back on it
adb shell rm /sdcard/update.zip
adb shell "reboot bootloader"
fastboot -i 0x0409 flash recovery backupRecovery.img
fastboot -i 0x0409 reboot
if exist backupRecovery.img (
del backupRecovery.img
)
ECHO #done!
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
