#!/bin/bash
serial="$1"

if [ -z "$serial" ]; then
    echo "Usage: $0 serial_number"
    exit 1
fi

set -ex

ftdi_conf=$(mktemp --suffix _ftdi_eeprom)
cat > "$ftdi_conf" <<EOF
vendor_id=0x0403
product_id=0x6011
manufacturer="trnila"
product="ftdi_quad_lin"
serial="${serial}"
use_serial=true
EOF

sudo ftdi_eeprom --flash-eeprom --device i:0x0403:0x6011 "$ftdi_conf"
rm -f "$ftdi_conf"

sudo cp ldattach@.service /etc/systemd/system/
sudo systemctl daemon-reload

sudo cp sllin.network /etc/systemd/network/
sudo networkctl reload

sudo tee /etc/udev/rules.d/80-ftdi_quad_lin.rules <<EOF
SUBSYSTEM=="tty", ATTRS{idVendor}=="0403", ATTRS{idProduct}=="6011", ATTRS{serial}=="$serial", ENV{SYSTEMD_WANTS}+="ldattach@%k.service"
EOF

sudo udevadm control --reload-rules
