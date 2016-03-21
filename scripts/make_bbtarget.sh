#!/bin/bash

# $1 is $(BUILDDIR)
# $2 is that make target
source ./openembedded-core/oe-init-build-env $1
bitbake $2
