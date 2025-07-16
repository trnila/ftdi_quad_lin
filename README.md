# FTDI Quad LIN

FTDI Quad-LIN is an FTDI-based board that enables communication with up to 4 LIN channels.

- 4x LIN master channels
- USB-C connector
- channel LED indication of power presence and communication activity
- power jack to power selected transceiver and its network

<img src="ftdi-quad-lin-case.webp">
<img src="ftdi-quad-lin.webp">

## Getting started
Install dkms driver for sllin module:
```
$ ./install_driver.sh
```

Then run following commands to:
- write given serial number into the device
- install a udev rule to start `ldattach@.service` on USB plug-in
- copy `sllin.network` file to automatically bringup `slcan` interface up

```
$ sudo apt install ftdi-eeprom
$ ./setup.sh some_serial_number
```

## Tests

Connect all channels to 2x PCAN-USB Pro, then install peak driver:
```sh
$ wget https://www.peak-system.com/quick/PLIN-Linux-Driver -O plin_linux_driver.tar.gz
$ tar -xf plin_linux_driver.tar.gz
$ cd peak-lin-driver-1.4.0
$ make
$ sudo make install
```

Then test all channels as masters by sending frames to the connected PCAN-USB device:
```
$ uv run pytest
```
