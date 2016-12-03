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
CRLIBM_SRC = crlibm_private exp-td exp-td-standalone expm1 expm1-standalone log-td log1p log10-td log2-td trigo_accurate trigo_fast asin-td acos-td atan_fast atan_accurate csh_fast rem_pio2_accurate
SCSLIB_SRC = scs_private scs2double double2scs multiplication_scs addition_scs zero_scs division_scs
CRLIBM_OBJ = $(patsubst %,crlibm_%.o,$(CRLIBM_SRC))
SCSLIB_OBJ = $(patsubst %,scslib_%.o,$(SCSLIB_SRC))
crlibm_function.oct: crlibm_api.o $(CRLIBM_OBJ) $(SCSLIB_OBJ)
	$(MKOCTFILE)  -o $@  $^
crlibm_api.o: crlibm_api.cc
	$(MKOCTFILE)  --compile -o $@  $<
$(CRLIBM_OBJ): crlibm_%.o: crlibm_bundle.c crlibm/%.c
	(cat $<; echo "#include \"crlibm/$*.c\"") > "_crlibm_$*.c"
	$(MKOCTFILE)  --compile -o $@ -Wno-div-by-zero -Wno-unused-variable -std=c99 -msse2 -mfpmath=sse "_crlibm_$*.c" || \
	$(MKOCTFILE)  --compile -o $@ -Wno-div-by-zero -Wno-unused-variable -std=c99 -O3 "_crlibm_$*.c"
	$(RM) "_crlibm_$*.c"
$(SCSLIB_OBJ): scslib_%.o: crlibm_bundle.c crlibm/scs_lib/%.c
	(cat $<; echo "#include \"crlibm/scs_lib/$*.c\"") > "_scslib_$*.c"
	$(MKOCTFILE)  --compile -o $@ -Wno-div-by-zero -Wno-unused-variable -std=c99 -msse2 -mfpmath=sse "_scslib_$*.c" || \
	$(MKOCTFILE)  --compile -o $@ -Wno-div-by-zero -Wno-unused-variable -std=c99 -O3 "_scslib_$*.c"
	$(RM) "_scslib_$*.c"

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
