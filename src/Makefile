SHELL        = /bin/sh
OBJ          = mpfr_function_d.oct \
               mpfr_matrix_mul_d.oct \
               mpfr_vector_sum_d.oct \
               mpfr_vector_dot_d.oct
LDFLAGS_MPFR = -lmpfr -lgmp

all: $(OBJ)

## Compile MPFR api oct-files
mpfr_%.oct: mpfr_%.cc mpfr_commons.cc
	$(MKOCTFILE)  -o $@ $(LDFLAGS_MPFR)  $<
