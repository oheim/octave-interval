SHELL   = /bin/sh

manual.html: manual.texinfo
	makeinfo --html --no-split "$<"

## PDF support is still experimental, so the default target is for
## generation of the HTML documentation only.
manual.pdf: manual.texinfo
	makeinfo --pdf "$<"
	rm *.aux *.cp *.fn *.ky *.log *.pg *.toc *.tp *.vr

.PHONY: clean
clean:
	rm manual.pdf manual.html
