SHELL     = /bin/sh
OBJ       = manual.html manual.pdf
MAKEINFO ?= makeinfo
VERSION  ?= $(shell grep "^Version: " ../packinfo/DESCRIPTION | cut -f2 -d" ")

.PHONY: all clean

all: $(OBJ)

manual.html: manual.texinfo $(wildcard chapter/*) license/gpl-3.0.texi
	$(MAKEINFO) -D 'version $(VERSION)' --html --no-split --css-include manual.css "$<"

manual.pdf: manual.texinfo $(wildcard chapter/*) license/gpl-3.0.texi $(wildcard image/*.pdf)
	$(MAKEINFO) --Xopt=--texinfo='@set version $(VERSION)' --pdf "$<"

clean:
	rm $(OBJ)
