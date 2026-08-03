#!/system/bin/sh

# Magisk uninstall script: stop daed and notify user

# Stop daed process
pkill -f 'daed run' >/dev/null 2>&1

ui_print "daed has been stopped."
ui_print "Config directory /data/adb/daed has been preserved."
ui_print "You may back it up or remove it manually if no longer needed."
