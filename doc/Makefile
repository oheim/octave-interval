SHELL = /bin/sh
OBJ   = manual.html manual.pdf

.PHONY: all clean

all: $(OBJ)

manual.html: manual.texinfo $(wildcard chapter/*) license/fdl-1.3.texi
	makeinfo --html --no-split "$<"

manual.pdf: manual.texinfo $(wildcard chapter/*) license/fdl-1.3.texi $(wildcard image/*.pdf)
	makeinfo --pdf --Xopt=--clean "$<"

clean:
	rm $(OBJ)
