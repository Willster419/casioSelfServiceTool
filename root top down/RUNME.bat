ECHO OFF
COLOR 9b
CLS
ECHO Casio Top Down Root Tool by: Willster419
ECHO By using the script you understand that this is done at YOUR own risk.
ECHO Make sure your phone has usb debugging mode enabled!
ECHO Make sure drivers are installed!
ECHO Phone screen must be ON AND UNLOCKED!
pause
ECHO #Starting Top Down root...
rem make sure device is there and set proper variables
ECHO #Please unlock your phone now
ECHO #Waiting for phone detection
adb wait-for-device
ECHO #Phone detected, waiting for phone unlock detection...
:checkLoopRoot1_1
adb shell sleep 1
for /f %%i in ('adb shell "dumpsys window windows | grep -E 'mCurrentFocus' | cut -c 33-40"') do set var8=%%i
if "Keyguard"=="%var8%" (
goto checkLoopRoot1_1
)
ECHO #Phone detected, moving to homescreen...
adb shell input keyevent 3
ping 1.1.1.1 -n 1 -w 500 > nul
rem if the wifi is on, turn it off
FOR /F "tokens=* USEBACKQ" %%F IN (`adb shell "dumpsys wifi | grep Wi-Fi"`) DO (
SET var=%%F
)
ECHO #%var%
adb shell sleep 1
if "%var%"=="Wi-Fi is enabled" (
ECHO #Turning off wifi...
adb shell am start -a android.intent.action.MAIN -n com.android.settings/.wifi.WifiSettings
adb shell sleep 1
adb shell input keyevent 20
adb shell input keyevent 23
)
rem copy a modified script to be run at startup
ECHO #copying modded file over to device...
adb push tools\init.qcom.sdio.sh.mod /system/etc/init.qcom.sdio.sh
ECHO #rebooting...
adb shell sleep 1
adb reboot
ECHO #waiting for full boot...
adb wait-for-device
adb shell sleep 10
:checkLoop1
rem checks to see if the phone is fully booted or not
adb shell sleep 1
for /f %%i in ('adb shell "getprop init.svc.bootanim"') do set var4=%%i
if "running"=="%var4%" (
goto checkLoop1
)
adb shell sleep 1
ECHO #rooting...
rem copy the superuser binary and application to the device
adb push tools\su /system/bin/su
adb push tools\superuser.apk /system/app/Superuser.apk
ECHO #rebooting..
adb shell sleep 1
adb reboot
ECHO #waiting for full boot...
adb wait-for-device
adb shell sleep 10
rem wait for a full boot again
:checkLoop2
adb shell sleep 1
for /f %%i in ('adb shell "getprop init.svc.bootanim"') do set var4=%%i
if "running"=="%var4%" (
goto checkLoop2
)
adb shell sleep 1
ECHO #verifying root...
ping 1.1.1.1 -n 1 -w 1000 > nul
rem verifies root by calling the help command to see if the su binary is installed
for /f %%i in ('adb shell su -h') do set var7=%%i
if "su:"=="%var7%" (
ECHO #root failed!
adb shell sleep 3
GOTO MENU
)
adb shell su -c "cp /system/bin/rm /system/etc/rm"
adb shell su -c "rm /system/etc/rm"
rem copies the busybox binary to the phone, then uses the busybox binary
rem itself to copy to the system partition and set the proper permissions
ECHO #Installing busybox...
adb push tools\busybox /data/local/tmp/busybox
adb shell su -c "chmod 755 /data/local/tmp/busybox"
adb shell su -c "/data/local/tmp/busybox mount -o remount,rw /system"
adb shell su -c "/data/local/tmp/busybox mkdir /system/xbin"
adb shell su -c "/data/local/tmp/busybox cp /data/local/tmp/busybox /system/xbin/busybox"
adb shell su -c "chmod 755 /system/xbin/busybox"
adb shell su -c "/system/xbin/busybox --install /system/xbin"
adb shell sleep 2
ECHO #rebooting...
adb reboot
adb wait-for-device
ECHO #waiting full boot...
adb wait-for-device
adb shell sleep 10
:checkLoop3
adb shell sleep 1
for /f %%i in ('adb shell "getprop init.svc.bootanim"') do set var4=%%i
if "running"=="%var4%" (
goto checkLoop3
)
adb shell sleep 1
rem installs the apks in the main directory
ECHO #installing unroot tool, root file manager and busybox updater...
adb install tools\unroot.apk
adb install tools\es.apk
adb install tools\busybox.apk
rem remounts the system to be re-writeable, removes any files copied, and
rem verifies all correct permissions are set
ECHO #cleaning up...
adb shell su -c "system/xbin/busybox mount -o remount,rw /system"
adb shell su -c "rm /system/etc/init.qcom.sdio.sh"
adb push tools\init.qcom.sdio.sh.orig /data/local/tmp/init.qcom.sdio.sh
adb shell su -c "system/xbin/busybox cp /data/local/tmp/init.qcom.sdio.sh /system/etc/init.qcom.sdio.sh"
adb shell su -c "rm /data/local/tmp/init.qcom.sdio.sh"
adb shell su -c "chmod 777 /system/etc/init.qcom.sdio.sh"
adb shell su -c "chmod 755 /system/bin"
adb shell su -c "chmod 755 /system/app"
adb shell su -c "chmod 755 /system"
ECHO #Done!
pause
GOTO MENU