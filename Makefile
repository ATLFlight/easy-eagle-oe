TOP := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

BUILDDIR = $(TOP)build
MACHINE ?= "eagle"
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

all: db410c

-include db410c_makefiles/db410c.mk

# OE Layers are managed via repo
.repo:
	@repo init -u https://github.com/DBOpenSource/eagle-manifest

.updated: .repo
	@repo sync
	@touch .updated

update: .repo
	@repo sync

.PHONY builddir: $(BUILDDIR)
$(BUILDDIR): .updated
	@mkdir -p $@
	@./scripts/init_builddir.sh $@

.PHONY bblayers: $(BUILDDIR) .conf_patched
.conf_patched: .updated
	@./scripts/update_bblayers.py $(BUILDDIR)/conf/bblayers.conf $(TOP)
	@sed -i 's/^MACHINE .*/MACHINE ?= $(MACHINE)/' $(BUILDDIR)/conf/local.conf
	@./scripts/update_local_conf.py $(BUILDDIR)/conf/local.conf $(TOP)
	@touch $@
	
# Build the rootfs
core-image: $(ROOTFS_IMG)
$(ROOTFS_IMG): bblayers $(FIRMWARE_ZIP)
	@[ -f $@ ] || ./scripts/make_bbtarget.sh $(BUILDDIR) core-image-minimal
	@echo "rootfs image created"

#core-image-x11: bblayers $(FIRMWARE_ZIP)
#	@./scripts/make_bbtarget.sh $(BUILDDIR) core-image-x11

# Build the Kernel
$(IMAGE) $(DTB): bblayers 
	@./scripts/make_bbtarget.sh $(BUILDDIR) linux-eagle

db410c: $(ROOTFS_IMG) $(BOOT_IMG)
	@echo "BOOT_IMG: $(BOOT_IMG)"
	@echo "ROOTFS_IMG: $(ROOTFS_IMG)"

clean-rootfs:
	@rm -f $(IMG_DIR)/core-image-minimal-eagle.ext4 rootfs.img
