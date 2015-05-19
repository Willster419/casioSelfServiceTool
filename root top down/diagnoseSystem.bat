adb shell ls -l /system/etc >ETC.txt
adb shell ls -l /system/bin >BIN.txt
adb shell ls -l /system >SYSTEM.txt
adb pull /system/etc/init.qcom.sdio.sh init.qcom.sdio.sh.dev