## This is part of the GNU Octave Interval Package.
## Copyright 2015-2016 Oliver Heimlich
## Copyright 2016 Mike Miller
## See the file COPYING for copying conditions.

SHELL          = /bin/sh
OBJ            = mpfr_function_d.oct \
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
	$(RM) *.oct *.o

.PHONY: all clean
