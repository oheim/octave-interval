SHELL      = /bin/sh
M_IMAGE    = $(wildcard image/*.m)
IMAGE_OBJ  = $(patsubst %,%.png,$(M_IMAGE))
OBJ        = manual.html manual.pdf $(IMAGE_OBJ)
MAKEINFO  ?= makeinfo
VERSION   ?= $(shell grep "^Version: " ../packinfo/DESCRIPTION ../DESCRIPTION | head -1 | cut -f2 -d" ")
OCTAVE    ?= octave

.PHONY: all clean

all: $(OBJ)

manual.html: manual.texinfo manual.init $(wildcard chapter/*) license/gpl-3.0.texi $(IMAGE_OBJ)
	$(MAKEINFO) -D 'version $(VERSION)' --html --no-split --init-file manual.init --css-include manual.css "$<"

manual.pdf: manual.texinfo $(wildcard chapter/*) license/gpl-3.0.texi $(wildcard image/*.pdf) $(IMAGE_OBJ)
	$(MAKEINFO) --Xopt=--texinfo='@set version $(VERSION)' --pdf "$<"

image/%.m.png: image/%.m
	$(OCTAVE) \
		--no-gui --no-init-file --no-site-file --silent --no-history \
		--eval "pkg ('load', 'interval');" \
		--eval "source ('$<'); __print_mesa__ (gcf, '$@');"
	@# The image size is too large for inclusion in the pdf,
	@# thus we increase the resolution from 150 to 250 dpi.
	convert -density 98.425 -units PixelsPerCentimeter "$@" "$@"

clean:
	rm $(OBJ)
