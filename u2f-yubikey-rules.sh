#!/bin/bash

wget https://raw.githubusercontent.com/Yubico/libu2f-host/master/70-u2f.rules 2>/dev/zero

if [ -f /etc/udev/rules.d/70-u2f.rules ]; then
    if diff /etc/udev/rules.d/70-u2f.rules 70-u2f.rules; then
        echo "##############################################################"
        echo ""
        echo "  You already have this yubikey rules file installed "
        echo ""
        echo "##############################################################"
        rm 70-u2f.rules
    fi
elif mv 70-u2f.rules /etc/udev/rules.d 2>/dev/null; then
    echo "##############################################################"
    echo ""
    echo "  Reboot to see changes."
    echo ""
    echo "##############################################################"
else
    echo "##############################################################"
    echo ""
    echo "  ERROR!"
    echo "  You must run this with write access to /etc/udev/rules.d/"
    echo ""
    echo "##############################################################"
fi
