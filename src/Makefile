SHELL        = /bin/sh
OBJ          = mpfr_function_d.oct    mpfr_function_d.cc-tst \
               mpfr_vector_sum_d.oct  mpfr_vector_sum_d.cc-tst \
               mpfr_vector_dot_d.oct  mpfr_vector_dot_d.cc-tst
LDFLAGS_MPFR = -lmpfr -lgmp

# The MKOCTFILE environment variable will be set by the package installation
# process of GNU Octave.
ifndef MKOCTFILE
MKOCTFILE    = mkoctfile
endif

.PHONY: all clean install uninstall

## Default target
all: $(OBJ)

## Compile MPFR api oct-files
mpfr_%.oct: mpfr_%.cc mpfr_commons.cc
	$(MKOCTFILE)  -o $@ $(LDFLAGS_MPFR)  $<

## Extract tests from oct-files
%.cc-tst: %.cc
	( echo "## DO NOT EDIT!  Generated automatically from $(<F) by Make."; grep '^%!' $< ) > $@-t
	mv $@-t $@

# The following build targets are not required for the package installation
# process, but are used during development of the package.

DEV_OBJ=$(OBJ:%=../inst/%)

../inst/%: %
	ln -srf $< $@

install: $(DEV_OBJ)

uninstall:
	rm -f $(DEV_OBJ)

clean:
	rm -f $(OBJ) $(OBJ:%.oct=%.o)
