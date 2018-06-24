## This is part of the GNU Octave Interval Package.
## Copyright 2018 Oliver Heimlich
## See the file COPYING for copying conditions.

SHELL = /bin/sh

## To be backwards compatible with old versions of Octave, we use wrapper
## functions around some core API functions.
##
## The implementation of the wrapper functions and other backwards
## compatibility code is split into .cc files for respective major versions
## of Octave.
##
## The needed implementation for octave.h is selected during installation.
OCTAVE_VERSION = $(shell $(OCTAVE_CONFIG) -p VERSION)
ifneq ($(filter 3.% 4.0.% 4.1.% 4.2.%,$(OCTAVE_VERSION)),)
SRC = octave_4.2.cc
else
SRC = octave_current.cc
endif
octave.cc: $(SRC)
	@echo "Detected Octave version: $(OCTAVE_VERSION)"
	cp "$<" "$@"

clean:
	$(RM) octave.cc
