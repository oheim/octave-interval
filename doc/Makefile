SHELL     = /bin/sh
OBJ       = manual.html manual.pdf
MAKEINFO ?= makeinfo

.PHONY: all clean

all: $(OBJ)

manual.html: manual.texinfo $(wildcard chapter/*) license/fdl-1.3.texi
	$(MAKEINFO) --html --no-split "$<"

manual.pdf: manual.texinfo $(wildcard chapter/*) license/fdl-1.3.texi $(wildcard image/*.pdf)
	$(MAKEINFO) --pdf "$<"

clean:
	rm $(OBJ)
