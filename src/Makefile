# The MKOCTFILE environment variable will be set by the package installation
# process of GNU Octave.

OBJ          = mpfr_function_d.oct
INC          = mpfr_commons.cc
LDFLAGS_MPFR = -lmpfr -lgmp

all: $(OBJ)

mpfr_%.oct: mpfr_%.cc $(INC)
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
