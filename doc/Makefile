## This is part of the GNU Octave Interval Package.
## Copyright 2015-2016 Oliver Heimlich.
## See the file COPYING for copying conditions.

SHELL      = /bin/sh
M_IMAGE    = $(wildcard image/*.m) $(patsubst %.m.texinfo,%.m,$(wildcard image/*.m.texinfo))
IMAGE_OBJ  = $(patsubst %,%.png,$(M_IMAGE))
OBJ        = manual.html manual.pdf $(IMAGE_OBJ)
MAKEINFO  ?= makeinfo
VERSION   ?= $(shell grep "^Version: " ../packinfo/DESCRIPTION ../DESCRIPTION | head -1 | cut -f2 -d" ")
OCTAVE    ?= octave

.PHONY: all clean images

all: $(OBJ)

images: $(IMAGE_OBJ)

manual.html: manual.texinfo $(wildcard chapter/*) license/gpl-3.0.texi $(wildcard image/*.texinfo) $(IMAGE_OBJ)
	$(MAKEINFO) -D 'version $(VERSION)' --html --no-split --css-include manual.css "$<"

manual.pdf: manual.texinfo $(wildcard chapter/*) license/gpl-3.0.texi $(wildcard image/*.texinfo) $(wildcard image/*.pdf) $(IMAGE_OBJ)
	$(MAKEINFO) --Xopt=--texinfo='@set version $(VERSION)' --pdf "$<"

image/%.m.png: image/%.m
	$(OCTAVE) \
		--no-gui --silent --no-history \
		--eval "source ('$<');" \
		--eval "__print_mesa__ (gcf, '$@');"
	@# The image size is too large for inclusion in the pdf,
	@# thus we increase the resolution from 150 to 250 dpi.
	convert -density 98.425 -units PixelsPerCentimeter "$@" "$@"

image/%.m: image/%.m.texinfo
	$(MAKEINFO) -D m-file --plaintext "$<" > "$@"

clean:
	rm $(OBJ)
