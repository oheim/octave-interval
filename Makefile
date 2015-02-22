SHELL   = /bin/sh

PACKAGE = $(shell grep "^Name: " DESCRIPTION | cut -f2 -d" ")
VERSION = $(shell grep "^Version: " DESCRIPTION | cut -f2 -d" ")

ifndef OCTAVE
OCTAVE    = octave
endif
ifndef MKOCTFILE
MKOCTFILE = mkoctfile
endif

.PHONY: help dist release html run check install clean md5

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
	rm -f $(PACKAGE)-$(VERSION).tar $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-html.tar.gz 
	rm -f src/*.oct src/*.o
	rm -f fntests.log

md5: $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-html.tar.gz
	@md5sum $^

$(PACKAGE)-$(VERSION).tar: .hg/dirstate
	@echo "Creating package release ..."
	@hg archive --exclude ".hg*" --exclude "Makefile" --exclude "*.sh" --exclude "src/*.itl" "$@"

$(PACKAGE)-$(VERSION).tar.gz: $(PACKAGE)-$(VERSION).tar
	@gzip -f -k "$<"

~/octave/$(PACKAGE)-$(VERSION)/packinfo/DESCRIPTION: $(PACKAGE)-$(VERSION).tar.gz
	@echo "Installing package in GNU Octave ..."
	@$(OCTAVE) --silent --eval "pkg install $<"

$(PACKAGE)-html/$(PACKAGE)/index.html: ~/octave/$(PACKAGE)-$(VERSION)/packinfo/DESCRIPTION
	@echo "Generating HTML documentation for the package. This may take a while ..."
	@$(OCTAVE) --silent --eval "pkg load generate_html; generate_package_html ('$(PACKAGE)', '$(PACKAGE)-html', 'octave-forge')"

$(PACKAGE)-html.tar.gz: $(PACKAGE)-html/$(PACKAGE)/index.html
	@tar czf $@ $(PACKAGE)-html

OCT_SOURCES = $(shell grep -l DEFUN_DLD src/*.cc | xargs echo)
OCT_FILES   = $(OCT_SOURCES:%.cc=%.oct)

src/%.oct: src/*.cc src/Makefile
	@echo "Compiling OCT-files ..."
	@(cd src; MKOCTFILE=$(MKOCTFILE) make)
	@touch --no-create $@

run: $(OCT_FILES)
	@echo "Run GNU Octave with the development version of the package"
	@$(OCTAVE) --silent --path "inst/" --path "src/"
	@echo

check: $(OCT_FILES)
	@echo "Testing package in GNU Octave ..."
	@$(OCTAVE) --silent --path "inst/" --path "src/" --eval "__run_test_suite__ ({'.'}, {})"
	@echo

###################################################################
## The following rules are required for generation of test files ##
###################################################################

TST_SOURCES  = $(shell ls -1 src/ | grep ".itl" | xargs echo)
TST_FILES    = $(TST_SOURCES:%.itl=inst/tests/%.tst)
PWD          = $(shell pwd)

.PHONY: tests
tests: $(TST_FILES)

inst/tests/%.tst: src/%.itl
	@echo "Compiling $@ ..."
	@(cd "$(ITF1788_HOME)/src" && python3 main.py -f "$(shell basename $<)" -c "(octave, native, P1788)" -o "$(PWD)/.build.tst" -s "$(PWD)/src")
	@mkdir -p "$(shell dirname $@)" && mv ".build.tst/octave/native/P1788/$(shell basename $@)" $@
	@rm -rf .build.tst/

ifdef ITF1788_HOME

clean: clean-tests
.PHONY: clean-tests
clean-tests:
	rm -rf inst/tests/

$(PACKAGE)-$(VERSION).tar.gz: patch-tests
.INTERMEDIATE: patch-tests
patch-tests: $(PACKAGE)-$(VERSION).tar $(TST_FILES) 
	@tar --append --file "$<" --transform="s!^inst/!$(PACKAGE)-$(VERSION)/inst/!" inst/tests/*

check: $(TST_FILES)

else

$(PACKAGE)-$(VERSION).tar.gz: ITF1788WARNING
.PHONY: ITF1788WARNING
ITF1788WARNING:
	@echo
	@echo "WARNING: ITF1788 not installed properly. The release will not contain"
	@echo "generated tests."
	@echo
	@echo "Download ITF1788 from https://github.com/nehmeier/ITF1788"
	@echo "and set the environment variable ITF1788_HOME accordingly."
	@echo

endif
