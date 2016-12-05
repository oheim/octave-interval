## This is part of the GNU Octave Interval Package.
## Copyright 2015-2016 Oliver Heimlich
## Copyright 2016 Mike Miller
## See the file COPYING for copying conditions.

SHELL          = /bin/sh
OBJ            = crlibm_function.oct \
                 mpfr_function_d.oct \
                 mpfr_linspace_d.oct \
                 mpfr_matrix_mul_d.oct \
                 mpfr_matrix_sqr_d.oct \
                 mpfr_to_string_d.oct \
                 mpfr_vector_sum_d.oct \
                 mpfr_vector_dot_d.oct \
                 __setround__.oct

LDFLAGS_MPFR   =-lmpfr
## Use important flags in XTRA_CFLAGS for OpenMP (workaround for bug #45280)
CFLAG_OPENMP   =$(findstring -fopenmp,$(shell $(MKOCTFILE) -p XTRA_CFLAGS))

all: $(OBJ)

## crlibm api oct-file
crlibm_function.oct: crlibm_function.o crlibm/crlibm_private.o
	$(MKOCTFILE)  -o $@  $< crlibm/*.o crlibm/scs_lib/*.o
crlibm_function.o: crlibm_function.cc
	$(MKOCTFILE)  --compile -o $@  $<

## bundled crlibm library
crlibm/crlibm_private.o: crlibm/crlibm_config.h
	$(MAKE) -C crlibm CFLAGS+="$(shell $(MKOCTFILE) -p CPICFLAG) -Wno-div-by-zero -Wno-unused-variable -Wno-unused-but-set-variable"
crlibm/crlibm_config.h:
	(cd crlibm && ./configure --disable-dependency-tracking --enable-sse2)

## GNU MPFR api oct-files
mpfr_matrix_mul_d.oct mpfr_matrix_sqr_d.oct : mpfr_%.oct: mpfr_%.cc mpfr_commons.cc
	$(MKOCTFILE)  -o $@ $(LDFLAGS_MPFR) $(CFLAG_OPENMP) $<
mpfr_%.oct: mpfr_%.cc mpfr_commons.cc
	$(MKOCTFILE)  -o $@ $(LDFLAGS_MPFR)  $<

## <cfenv> api oct-file
##
## Note to redistributors:
## If you can't compile this function for a particular platform
## or `test @infsup/mtimes` throws a warning in Octave, you can safely
## omit the __setround__ function from a redistributed binary package.
## However, please inform the package maintainer of the error.
__setround__.oct: __setround__.cc
	$(MKOCTFILE)  -o $@  $<

clean:
	$(MAKE) -C crlibm $@
	$(RM) *.oct *.o

.PHONY: all clean
