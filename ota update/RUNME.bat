ECHO OFF
COLOR 9b
CLS
ECHO Casio Update Tool by: Willster419
ECHO By using the script you understand that this is done at YOUR own risk.
ECHO Make sure you have drivers installed and usb debugging mode enabled!
pause
cls
ECHO #This update requires the following:
ECHO #root access (will be tested for)
ECHO #a supported phone model (will be tested for)
pause
ECHO #Checking if your phone build version is supported...
adb wait-for-device
ping 1.1.1.1 -n 1 -w 500 > nul
for /f %%i in ('adb shell "getprop ro.build.id | cut -c 5-8"') do set var5=%%i
if not exist "bootImage/stock/%var5% stock boot.img" (
GOTO NS
)
if not exist "recoveryImage/%var5% stock recovery.img" (
GOTO NS
)
ECHO #Your phone version is supported!
ping 1.1.1.1 -n 1 -w 500 > nul
ECHO #Checking if your phone build version is supported for update...
adb wait-for-device
ping 1.1.1.1 -n 1 -w 500 > nul
for /f %%i in ('adb shell "getprop ro.build.id | cut -c 5-8"') do set var5=%%i
if "%var5%"=="M150"(
ECHO #your phone build is already the latest build version
ping 1.1.1.1 -n 1 -w 3000 > nul
GOTO MENU
)
if "%var5%"=="M140"(
ECHO #your phone build is supported for update!
ping 1.1.1.1 -n 1 -w 2000 > nul
GOTO updateSupported
)
if "%var5%"=="M130"(
ECHO #your phone build is supported for update!
ping 1.1.1.1 -n 1 -w 2000 > nul
GOTO updateSupported
)
ECHO #Error: your phone build version is not supported for update
ECHO #Contact willster419@outlook.com for details
ECHO #Have your build id ready for when you email
pause
GOTO MENU
:updateSupported
ECHO #preparing for update...
rem verifies root by calling the help command to see if the su binary is installed
for /f %%i in ('adb shell su -h') do set var12=%%i
if "%var12%"=="su:" (
GOTO NR
)
adb shell su -c "rm /mnt/sdcard/ipth_package.bin" > nul
adb push inopathUpdate\%var5%Update.bin /sdcard/ipth_package.bin
ECHO #rebooting...
adb reboot bootloader
fastboot -i 0x0409 flash boot "bootImage/stock/%var5% stock boot.img"
fastboot -i 0x0409 flash recovery "recoveryImage/%var5% stock recovery.img"
fastboot -i 0x0409 reboot
ECHO #device prepared, waiting for full boot and sdcard mount...
adb wait-for-device
:checkLoopUpdate
adb shell sleep 10
for /f %%i in ('adb shell "getprop init.svc.bootanim"') do set var4=%%i
if "running"=="%var4%" (
goto checkLoopUpdate
)
adb shell sleep 1
ECHO #setting phone to update and rebooting...
adb shell "echo '--update_package=SDCARD:ipth_package.bin' >> /cache/recovery/command"
rem adb shell su -c "ECHO #'--update_package=/sdcard/ipth_package.bin' >> /cache/recovery/command"
adb reboot recovery
ECHO #You will NEED to do a battery pull AFTER the update is done
ECHO #(When its just the android guy with the exclamation point).
ECHO #Also please keep in mind that if you want GNM recovery
ECHO #of the modded boot image of the new firmware (if it exists yet)
ECHO #you need to reflash it from the flash menu. You will also have
ECHO #to delete the ipth_update from your sdcard
pause
GOTO MENU

:NS
ECHO #Error: Your phone version is not supported. Send an email
ECHO #to willster419@outlook.com to get it supported.
ECHO #Please include your phone version, and run the "dump images"
ECHO #option and attach the boot.img for quick support.
pause
GOTO MENU

:NR
ECHO #Error: Your phone is not rooted. In order to continue
ECHO #with the requested operation, you need to root your
ECHO #phone first.
ping 1.1.1.1 -n 1 -w 7000 > nul
GOTO MENU