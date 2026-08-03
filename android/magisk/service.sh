#!/system/bin/sh

# Magisk late_start service: auto-start daed on boot

# Fallback MODPATH for manual execution
MODPATH=${MODPATH:-/data/adb/modules/daed}

# Wait for system/network to be ready
sleep 5

# Prevent duplicate instances
if pgrep -f 'daed run' >/dev/null 2>&1 || pidof daed >/dev/null 2>&1; then
    exit 0
fi

# Locate the daed binary: prefer MODPATH, fall back to PATH
DAED_BIN="$MODPATH/system/bin/daed"
if [ ! -x "$DAED_BIN" ]; then
    DAED_BIN="daed"
fi

# Launch daed in background
nohup "$DAED_BIN" run -c /data/adb/daed >/dev/null 2>&1 &
