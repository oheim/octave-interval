SHELL          = /bin/sh
OBJ            = mpfr_function_d.oct \
                 mpfr_matrix_mul_d.oct \
                 mpfr_to_string_d.oct \
                 mpfr_vector_sum_d.oct \
                 mpfr_vector_dot_d.oct \
                 __setround__.oct
LDFLAGS_MPFR   =-lmpfr -lgmp
STD_CXXFLAGS   =$(shell $(MKOCTFILE) -p CXXFLAGS)
CPP11_CXXFLAGS =$(STD_CXXFLAGS) -std=c++11
## Use important flags in XTRA_CFLAGS for OpenMP (workaround for bug #45280)
XTRA_CFLAGS    =$(shell $(MKOCTFILE) -p XTRA_CFLAGS)

all: $(OBJ)

## MPFR api oct-files
mpfr_matrix_mul_d.oct: mpfr_%.oct: mpfr_%.cc mpfr_commons.cc
	$(MKOCTFILE)  -o $@ $(LDFLAGS_MPFR) $(XTRA_CFLAGS) $<
mpfr_%.oct: mpfr_%.cc mpfr_commons.cc
	$(MKOCTFILE)  -o $@ $(LDFLAGS_MPFR)  $<

## cfenv api oct-file
__setround__.oct: __setround__.cc
	CXXFLAGS="$(CPP11_CXXFLAGS)"  $(MKOCTFILE)  -o $@  $<
