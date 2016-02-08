SHELL          = /bin/sh

## Copyright 2015-2016 Oliver Heimlich
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

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
