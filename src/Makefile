# The MKOCTFILE environment variable will be set by the package installation
# process of GNU Octave.

OBJ          = mpfr_function_d.oct \
               mpfr_vector_sum_d.oct \
               mpfr_vector_dot_d.oct
LDFLAGS_MPFR = -lmpfr -lgmp

all: $(OBJ)

mpfr_%.oct: mpfr_%.cc mpfr_commons.cc
	$(MKOCTFILE) $(CFLAGS) -o $@ $(LDFLAGS) $(LDFLAGS_MPFR)  $<

# The following build target are not required for the package installation
# process, but are used during development of the package.

.PHONY: clean uninstall

install: all
	ln -srf $(OBJ) ../inst/

uninstall:
	(cd ../inst/; rm -f $(OBJ))

clean:
	rm -f $(OBJ) $(OBJ:%.oct=%.o)