ECHO OFF
COLOR 9b
CLS
ECHO Casio Update Tool by: Willster419
ECHO By using the script you understand that this is done at YOUR own risk.
ECHO Make sure you have drivers installed and usb debugging mode enabled!
pause
cls
ECHO This update requires the following:
ECHO sdcard with FAT or FAT32 format (exFAT will not work!)
ECHO MXXX stock boot.img (MXXX meaning your phone version)
ECHO placed in the stockImages folder and renamed to boot.img
ECHO MXXX stock recovery.img (MXXX meaning your phone version)
ECHO placed in the stockImages folder and renamed to recovery.img
ECHO the inopath update to flash located in inopathUpdate\ipth_package.bin
pause
if not exist stockImages/recovery.img (
ECHO recovery.img not detected
goto ND
)
if not exist stockImages/boot.img (
ECHO boot.img not detected
goto ND
)
if not exist inopathUpdate/ipth_package.bin (
ECHO inopath update not detected
goto UND
)
set var3=running
ECHO preparing for update...
adb wait-for-device
adb shell su -c "rm /mnt/sdcard/ipth_package.bin" > nul
adb push inopathUpdate\ipth_package.bin /sdcard/ipth_package.bin
ECHO rebooting...
adb reboot bootloader
fastboot -i 0x0409 flash boot stockImages\boot.img
fastboot -i 0x0409 flash recovery stockImages\recovery.img
fastboot -i 0x0409 reboot
ECHO device prepared, waiting for full boot and sdcard mount...
adb wait-for-device
:checkLoop1F
adb shell sleep 1
for /f %%i in ('adb shell "getprop init.svc.bootanim"') do set var4=%%i
if "%var3%"=="%var4%" (
goto checkLoop1F
)
adb shell sleep 1
ECHO setting phone to update and rebooting...
adb shell su -c "echo '--update_package=/sdcard/ipth_package.bin' >> /cache/recovery/command"
adb reboot recovery
ECHO You will NEED to do a battery pull AFTER the update is done
ECHO (When its just the android guy with the exclamation point).
ECHO Also please keep in mind that if you want GNM recovery
ECHO of the modded boot image of the new firmware (if it exists yet)
ECHO you need to reflash it from the flash menu. You will also have
ECHO to delete the ipth_update from your sdcard
pause
ECHO Done!
ping 1.1.1.1 -n 1 -w 1000 > nul
GOTO EXIT

:ND
ECHO one or both of the image files were not detected
ECHO exiting...
ping 1.1.1.1 -n 1 -w 3000 > nul
goto MENU

:UND
ECHO inopath update file not detected
ECHO exiting...
ping 1.1.1.1 -n 1 -w 3000 > nul
goto MENU
