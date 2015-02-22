SHELL   = /bin/sh

PACKAGE = $(shell grep "^Name: " DESCRIPTION | cut -f2 -d" ")
VERSION = $(shell grep "^Version: " DESCRIPTION | cut -f2 -d" ")

ifndef OCTAVE
OCTAVE    = octave
endif
ifndef MKOCTFILE
MKOCTFILE = mkoctfile
endif

.PHONY = help dist release html run check install clean md5

help:
	@echo
	@echo "Usage:"
	@echo "   make dist     Create $(PACKAGE)-$(VERSION).tar.gz for release"
	@echo "   make html     Create $(PACKAGE)-html.tar.gz for release"
	@echo "   make release  Create both of the above plus md5 sums"
	@echo
	@echo "   make install  Install the package in GNU Octave"
	@echo "   make check    Execute package tests (w/o install)"
	@echo "   make run      Run the package in GNU Octave (w/o install)"
	@echo
	@echo "   make clean    Cleanup"
	@echo

dist: $(PACKAGE)-$(VERSION).tar.gz

release: dist html md5
	@echo "Upload @ https://sourceforge.net/p/octave/package-releases/new/"
	@echo "Execute: hg tag \"release-$(VERSION)\""

html: $(PACKAGE)-html.tar.gz

install: ~/octave/$(PACKAGE)-$(VERSION)/packinfo/DESCRIPTION

clean:
	rm -rf $(PACKAGE)-html
	rm -f $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-html.tar.gz 
	rm -f src/*.oct src/*.o
	rm -f fntests.log

md5: $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-html.tar.gz
	@md5sum $^

$(PACKAGE)-$(VERSION).tar.gz: .hg/dirstate
	hg archive --exclude ".hg*" --exclude "*.sh" --exclude "Makefile" $@

~/octave/$(PACKAGE)-$(VERSION)/packinfo/DESCRIPTION: $(PACKAGE)-$(VERSION).tar.gz
	$(OCTAVE) --silent --eval "pkg install $<"

$(PACKAGE)-html/$(PACKAGE)/index.html: ~/octave/$(PACKAGE)-$(VERSION)/packinfo/DESCRIPTION
	$(OCTAVE) --silent --eval "pkg load generate_html; generate_package_html ('$(PACKAGE)', '$(PACKAGE)-html', 'octave-forge')"

$(PACKAGE)-html.tar.gz: $(PACKAGE)-html/$(PACKAGE)/index.html
	tar czf $@ $(PACKAGE)-html

OCT_SOURCES = $(shell grep -l DEFUN_DLD src/*.cc | xargs echo)
OCT_FILES   = $(OCT_SOURCES:%.cc=%.oct)

src/%.oct: src/*.cc src/Makefile
	(cd src; MKOCTFILE=$(MKOCTFILE) make)

run: $(OCT_FILES)
	# Run GNU Octave with the development version of the package
	$(OCTAVE) --silent --path "inst/" --path "src/"
	@echo

check: $(OCT_FILES)
	$(OCTAVE) --silent --path "inst/" --path "src/" --eval "__run_test_suite__ ({'.'}, {})"
	@echo
