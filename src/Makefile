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
ifneq (,$(findstring -fopenmp,$(shell $(MKOCTFILE) -p ALL_CFLAGS)))
## If OpenMP is activated, we must also enable linking (bug #45280)
LDFLAGS_GOMP   =-lgomp
else
LDFLAGS_GOMP   =
endif

all: $(OBJ)

## MPFR api oct-files
mpfr_matrix_mul_d.oct: mpfr_%.oct: mpfr_%.cc mpfr_commons.cc
	$(MKOCTFILE)  -o $@ $(LDFLAGS_MPFR) $(LDFLAGS_GOMP) $<
mpfr_%.oct: mpfr_%.cc mpfr_commons.cc
	$(MKOCTFILE)  -o $@ $(LDFLAGS_MPFR)  $<

## cfenv api oct-file
__setround__.oct: __setround__.cc
	CXXFLAGS="$(CPP11_CXXFLAGS)"  $(MKOCTFILE)  -o $@  $<
