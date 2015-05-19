ECHO OFF
COLOR 9b
CLS
ECHO Casio Top Down Root Tool by: Willster419
ECHO By using the script you understand that this is done at YOUR own risk.
ECHO Make sure your phone has usb debugging mode enabled!
ECHO Make sure drivers are installed!
ECHO Phone screen must be ON AND UNLOCKED!
pause
ECHO Starting Top Down root...
adb wait-for-device
set var6=su:
set var3=running
adb wait-for-device
FOR /F "tokens=* USEBACKQ" %%F IN (`adb shell "dumpsys wifi | grep Wi-Fi"`) DO (
SET var=%%F
)
ECHO %var%
adb shell sleep 1
set var2=Wi-Fi is enabled
if "%var%"=="%var2%" (
ECHO Turning off wifi...
adb shell am start -a android.intent.action.MAIN -n com.android.settings/.wifi.WifiSettings
adb shell sleep 1
adb shell input keyevent 20
adb shell input keyevent 23
)
ECHO copying modded file over to device...
adb push init.qcom.sdio.sh.mod /system/etc/init.qcom.sdio.sh
ECHO rebooting...
adb shell sleep 1
adb reboot
ECHO waiting for full boot...
adb wait-for-device
adb shell sleep 10
:checkLoop1
adb shell sleep 1
for /f %%i in ('adb shell "getprop init.svc.bootanim"') do set var4=%%i
if "%var3%"=="%var4%" (
goto checkLoop1
)
adb shell sleep 1
ECHO rooting...
adb push su /system/bin/su
adb push Superuser.apk /system/app/Superuser.apk
ECHO rebooting..
adb shell sleep 1
adb reboot
ECHO waiting for full boot...
adb wait-for-device
adb shell sleep 10
:checkLoop2
adb shell sleep 1
for /f %%i in ('adb shell "getprop init.svc.bootanim"') do set var4=%%i
if "%var3%"=="%var4%" (
goto checkLoop2
)
adb shell sleep 1
ECHO verifying root...
ping 1.1.1.1 -n 1 -w 1000 > nul
for /f %%i in ('adb shell su -c "cp /system/bin/rm /system/etc/rm"') do set var7=%%i
if "%var6%"=="%var7%" (
ECHO ROOT FAILED!
adb shell sleep 3
GOTO FAIL
)
adb shell su -c "cp /system/bin/rm /system/etc/rm"
adb shell su -c "rm /system/etc/rm"
ECHO Installing busybox...
adb push busybox /data/local/tmp/busybox
adb shell su -c "chmod 755 /data/local/tmp/busybox"
adb shell su -c "/data/local/tmp/busybox mount -o remount,rw /system"
adb shell su -c "/data/local/tmp/busybox mkdir /system/xbin"
adb shell su -c "/data/local/tmp/busybox cp /data/local/tmp/busybox /system/xbin/busybox"
adb shell su -c "chmod 755 /system/xbin/busybox"
adb shell su -c "/system/xbin/busybox --install /system/xbin"
adb shell sleep 2
ECHO rebooting...
adb reboot
adb wait-for-device
ECHO waiting full boot...
adb wait-for-device
adb shell sleep 10
:checkLoop3
adb shell sleep 1
for /f %%i in ('adb shell "getprop init.svc.bootanim"') do set var4=%%i
if "%var3%"=="%var4%" (
goto checkLoop3
)
adb shell sleep 1
ECHO installing unroot tool, root file manager and busybox updater...
adb install unroot.apk
adb install es.apk
adb install busybox.apk
ECHO cleaning up...
adb shell su -c "system/xbin/busybox mount -o remount,rw /system"
adb shell su -c "rm /system/etc/init.qcom.sdio.sh"
adb push init.qcom.sdio.sh.orig /data/local/tmp/init.qcom.sdio.sh
adb shell su -c "system/xbin/busybox cp /data/local/tmp/init.qcom.sdio.sh /system/etc/init.qcom.sdio.sh"
adb shell su -c "rm /data/local/tmp/init.qcom.sdio.sh"
adb shell su -c "chmod 777 /system/etc/init.qcom.sdio.sh"
adb shell su -c "chmod 755 /system/bin"
adb shell su -c "chmod 755 /system/app"
adb shell su -c "chmod 755 /system"
ECHO Done!
adb shell sleep 3
GOTO EXIT

:FAIL
GOTO EXIT
