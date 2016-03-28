TOP := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

BUILDDIR = $(TOP)build
IMG_DIR=$(TOP)build/tmp-glibc/deploy/images/eagle/

# Add skales to the path
PATH:=$(TOP)skales:$(PATH)
TMP_DIR=$(TOP)tmp
DOWNLOAD_DIR=$(TOP)downloads
IMAGE:=$(IMG_DIR)Image
DTB:=$(IMG_DIR)Image-apq8074-sbc.dtb
BOOT_IMG:=$(TOP)boot-eagle.img
ROOTFS_IMG:=$(IMG_DIR)core-image-minimal-eagle.ext4
FIRMWARE_DEST_DIR:=meta-eagle/recipes-firmware/firmware/files/

all: eagle

# OE Layers are managed via repo
.repo:
	@repo init -u https://github.com/ATLFlight/eagle-manifest

.updated: .repo
	@repo sync
	@touch $@


external/Flight_BSP_3.0_apq8074-le-1-0_r00015.zip:
	@mkdir -p external
	@echo "======================================================"
	@echo " NOTE: You have to download Flight_BSP_3.0_apq8074-le-1-0_r00015.zip"
	@echo " This is available from the Intrinsyc website for customers with a"
	@echo " registered Snapdragon Flight board"
	@echo " Go to: http://support.intrinsyc.com/projects/snapdragon-flight/files"
	@echo " Copy Flight_BSP_3.0_apq8074-le-1-0_r00015.zip to meta-eagle/recipes-firmware/firmware/files/"
	@echo "======================================================"
	@false

.PHONY eagle-firmware: meta-eagle/recipes-firmware/firmware/files/Flight_BSP_3.0_apq8074-le-1-0_r00015.zip
meta-eagle/recipes-firmware/firmware/files/Flight_BSP_3.0_apq8074-le-1-0_r00015.zip: external/Flight_BSP_3.0_apq8074-le-1-0_r00015.zip .updated
	[ -L meta-eagle/recipes-firmware/firmware/files/Flight_BSP_3.0_apq8074-le-1-0_r00015.zip ] || \
		(cd meta-eagle/recipes-firmware/firmware/files/ && ln -s ../../../../external/Flight_BSP_3.0_apq8074-le-1-0_r00015.zip .)

update: .repo
	@repo sync

.PHONY builddir: $(BUILDDIR)
$(BUILDDIR): .updated
	@mkdir -p $@
	@./scripts/init_builddir.sh $@

# Build the rootfs
core-image: $(ROOTFS_IMG) 
$(ROOTFS_IMG): eagle-firmware
	@[ -f $@ ] || ./scripts/make_bbtarget.sh $(BUILDDIR) core-image-minimal
	@echo "rootfs image created"

#core-image-x11: eagle-firmware
#	@./scripts/make_bbtarget.sh $(BUILDDIR) core-image-x11

# Build the Kernel
$(IMAGE) $(DTB): eagle-firmware
	@./scripts/make_bbtarget.sh $(BUILDDIR) linux-eagle

eagle: $(ROOTFS_IMG) $(BOOT_IMG)
	@echo "BOOT_IMG: $(BOOT_IMG)"
	@echo "ROOTFS_IMG: $(ROOTFS_IMG)"

clean-rootfs:
	@rm -f $(IMG_DIR)/core-image-minimal-eagle.ext4 rootfs.img
