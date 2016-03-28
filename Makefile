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

GCC4_8:=gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux
GCC4_8_URL:=http://releases.linaro.org/14.04/components/toolchain/binaries/${GCC4_8}.tar.xz

all: db410c

-include db410c_makefiles/db410c.mk

# OE Layers are managed via repo
.repo:
	@repo init -u https://github.com/ATLFlight/eagle-manifest

.updated: .repo
	@repo sync
	@touch .updated


external/gcc-linaro-arm-linux-gnueabihf-4.8-2014.04_linux:
	mkdir -p external
	[ -f external/${GCC4_8}.tar.xz ] || (cd external && wget -N ${GCC4_8_URL})
	cd external && unxz ${GCC4_8}.tar.xz
	cd external && tar xv ${GCC4_8}.tar

update: .repo
	@repo sync

.PHONY builddir: $(BUILDDIR)
$(BUILDDIR): .updated
	@mkdir -p $@
	@./scripts/init_builddir.sh $@

# Build the rootfs
core-image: $(ROOTFS_IMG)
$(ROOTFS_IMG): external/${GCC4_8} $(FIRMWARE_ZIP)
	@[ -f $@ ] || ./scripts/make_bbtarget.sh $(BUILDDIR) core-image-minimal
	@echo "rootfs image created"

#core-image-x11: bblayers $(FIRMWARE_ZIP)
#	@./scripts/make_bbtarget.sh $(BUILDDIR) core-image-x11

# Build the Kernel
$(IMAGE) $(DTB): external/${GCC4_8} 
	@./scripts/make_bbtarget.sh $(BUILDDIR) linux-eagle

db410c: $(ROOTFS_IMG) $(BOOT_IMG)
	@echo "BOOT_IMG: $(BOOT_IMG)"
	@echo "ROOTFS_IMG: $(ROOTFS_IMG)"

clean-rootfs:
	@rm -f $(IMG_DIR)/core-image-minimal-eagle.ext4 rootfs.img
