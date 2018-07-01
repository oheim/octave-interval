## This is part of the GNU Octave Interval Package.
## Copyright 2015-2018 Oliver Heimlich
## Copyright 2016 Mike Miller
## See the file COPYING for copying conditions.

SHELL          = /bin/sh
OBJ            = crlibm_function.oct \
                 intervaltotext.oct \
                 mpfr_function_d.oct \
                 mpfr_linspace_d.oct \
                 mpfr_matrix_mul_d.oct \
                 mpfr_matrix_sqr_d.oct \
                 mpfr_to_string_d.oct \
                 mpfr_vector_sum_d.oct \
                 mpfr_vector_dot_d.oct \
                 __setround__.oct

BUNDLED_CRLIBM_DIR = crlibm

LDFLAGS_MPFR   =-lmpfr
## Use important flags in XTRA_CFLAGS for OpenMP (workaround for bug #45280)
CFLAG_OPENMP   =$(findstring -fopenmp,$(shell $(MKOCTFILE) -p XTRA_CFLAGS))

## Auto-detect SSE2 for configuration of crlibm
## Ask the compiler to allow cross-compilation
SSE2_MACRO_DEF =$(shell echo \
                        | $(shell $(MKOCTFILE) -p CC) \
                          $(shell $(MKOCTFILE) -p CFLAGS) \
                          -dM -E - \
                        | grep "__SSE2__" | grep "1" )
ifneq ($(SSE2_MACRO_DEF),)
CONF_FLAG_SSE2 ?=--enable-sse2
endif

all: $(OBJ)

## crlibm api oct-file
crlibm_function.oct: crlibm_function.o $(BUNDLED_CRLIBM_DIR)/crlibm_private.o
	@echo " [MKOCTFILE] $<"
	@$(MKOCTFILE)  -o $@  $< $(BUNDLED_CRLIBM_DIR)/*.o $(BUNDLED_CRLIBM_DIR)/scs_lib/*.o
crlibm_function.o: crlibm_function.cc
	@echo " [MKOCTFILE] $<"
	@$(MKOCTFILE)  --compile -o $@  $<

## bundled crlibm library
##
## Note to redistributors:
## If you can't compile this library for a particular platform
## or `__check_crlibm__` throws a warning in Octave, you can safely
## omit the crlibm library from a redistributed binary package,
## (you must keep __check_crlibm__.m).
## However, please inform the package maintainer of the error.
$(BUNDLED_CRLIBM_DIR)/crlibm_private.o: $(BUNDLED_CRLIBM_DIR)/crlibm_config.h
	$(MAKE) -C $(BUNDLED_CRLIBM_DIR) CFLAGS+="$(shell $(MKOCTFILE) -p CPICFLAG) -Wno-div-by-zero -Wno-unused-variable -Wno-unused-but-set-variable"
$(BUNDLED_CRLIBM_DIR)/crlibm_config.h:
	(cd $(BUNDLED_CRLIBM_DIR) && ./configure --disable-dependency-tracking $(CONF_FLAG_SSE2))

## Wrapper functions for backwards compatibility with old Octave versions
OCTAVE_COMPATIBILITY = compatibility/octave.h compatibility/octave.cc
compatibility/octave.cc: $(filter-out $(OCTAVE_COMPATIBILITY),$(wildcard compatibility/*))
	@echo " [MAKE] compatibility"
	@$(MAKE) -C compatibility
	@touch "$@"

## GNU MPFR api oct-files
mpfr_matrix_mul_d.oct mpfr_matrix_sqr_d.oct : mpfr_%.oct: mpfr_%.cc mpfr_commons.h $(OCTAVE_COMPATIBILITY)
	@echo " [MKOCTFILE] $<"
	@$(MKOCTFILE)  -o $@ $(LDFLAGS_MPFR) $(CFLAG_OPENMP) $<
mpfr_%.oct: mpfr_%.cc mpfr_commons.h $(OCTAVE_COMPATIBILITY)
	@echo " [MKOCTFILE] $<"
	@$(MKOCTFILE)  -o $@ $(LDFLAGS_MPFR)  $<

intervaltotext.oct: intervaltotext.cc mpfr_commons.h $(OCTAVE_COMPATIBILITY)
	@echo " [MKOCTFILE] $<"
	@$(MKOCTFILE)  -o $@ $(LDFLAGS_MPFR)  $<

## <cfenv> api oct-file
##
## Note to redistributors:
## If you can't compile this function for a particular platform
## or `test @infsup/mtimes` throws a warning in Octave, you can safely
## omit the __setround__ function from a redistributed binary package.
## However, please inform the package maintainer of the error.
__setround__.oct: __setround__.cc
	@echo " [MKOCTFILE] $<"
	@$(MKOCTFILE)  -o $@  -Wno-unknown-pragmas  $<

clean:
	test ! -e $(BUNDLED_CRLIBM_DIR)/Makefile || $(MAKE) -C $(BUNDLED_CRLIBM_DIR) $@
	$(MAKE) -C compatibility
	$(RM) *.oct *.o

.PHONY: all clean
