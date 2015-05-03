SHELL   = /bin/sh
OBJ     = manual.pdf manual.html

all: $(OBJ)

%.pdf: %.texinfo
	makeinfo --pdf "$<"
	rm *.aux *.cp *.fn *.ky *.log *.pg *.toc *.tp *.vr

%.html: %.texinfo
	makeinfo --html --no-split "$<"

.PHONY: clean
clean:
	rm $(OBJ)
