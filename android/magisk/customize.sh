#!/system/bin/sh

# Magisk installation script for daed module

ui_print "==============================="
ui_print "  daed Magisk Module"
ui_print "==============================="
ui_print "Installing daed for Android..."

# Set executable permissions for binaries
# Magisk overlays system/ onto /system automatically, no manual copy needed
set_perm_recursive "$MODPATH/system/bin" 0 0 0755 0755

ui_print ""
ui_print "daed installed successfully!"
ui_print ""
ui_print "Quick access:"
ui_print "  Run 'daed-open' to open the web panel"
ui_print "  Panel URL: http://127.0.0.1:2023"
ui_print ""
ui_print "Installation completed."
