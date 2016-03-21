# easy-eagle-oe

## Overview
Generate a kernel and system image for the DB410C using simple make commands.

The Eagle board (Snapdragon Flight) uses Android boot images so there is some conversion required for the
kernel and DTB file and this is handled in the Makefile.

## Building the boot and rootfs images

``` shell
git clone https://github.com/ATLFlight/easy-eagle-oe.git
cd easy-eagle-oe
```

If Android is currently on the device, you will need to repartition the eMMC.
Use the recovery SD image to boot to fastboot, connect the ADB cable, and then run:

```
make setup-emmc
```

To get the firmware run:
```
make
```
 
Follow instructions to download the firmware, then:

```
make 
```

You may then want to make coffee... or breakfast...
or lunch... or potentially all of these depending on the speed of
your machine and your internet connection.

## Flashing the boot and rootfs images

Once the build completes, use the recover SD image to boot to fastboot, connect the 
ADB cable and then you can flash the images to the device:

```
make flash-bootimg
make flash-rootfs
```

## Booting into the new rootfs
Remove the ADB cable, pop out the recovery SD image, and cycle the power on the board.
The board should boot to a login prompt and the login is root. No password is needed.

To expand the root image to use the entire rootfs partition at the root prompt 
on the device run:

```
resize2fs /dev/disk/by-partlabel rootfs
```

