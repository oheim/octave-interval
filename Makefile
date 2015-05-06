SHELL   = /bin/sh

## Copyright 2015 Oliver Heimlich
##
## Copying and distribution of this file, with or without modification,
## are permitted in any medium without royalty provided the copyright
## notice and this notice are preserved.  This file is offered as-is,
## without any warranty.

## This file helps the package maintainer to
##   1. run the development version
##   2. check that all tests pass
##   3. prepare the release 
##
## This Makefile is _not_ meant to be portable. In order to use it, you
## have to install certain dependencies. This file is not distributed in
## the release tarball, so its dependencies must be met by developers only.
##
## It is intended that users of the release tarball do not need to install
## the tools and generators used here!
##
## DEPENDENCIES
##   * You should use GNU make and a GNU operating system. So far, this
##     Makefile has been used with Debian GNU/Linux 8 only and is not
##     guaranteed to work on other systems.
##
##     For example, doctest will fail on Windows, because console output
##     uses singlebyte characters on Windows and multibyte characters
##     on better systems.
##
##   * Interval Testing Framework for IEEE 1788
##
##     The tool is used to convert test/*.itl into GNU Octave *.tst files
##     for validation of the package.
##
##     Check out with git from https://github.com/oheim/ITF1788
##     [this should be the branch with the latest Octave specific extensions]
##     Set the environment variable ITF1788_HOME to the local git workspace,
##     e. g. in .bashrc:
##	 export ITF1788_HOME=/home/oliver/Dokumente/ITF1788
##
##     It is important to have a local git workspace, because the generated
##     files will be tagged with the generator version.
##
##     See its requirements.txt file for required python packages.
##
##   * Doctest
##
##     The tool is used to find errors in the code of @example blocks
##     from the documentation.
##
##     Download from https://github.com/catch22/doctest-for-matlab
##     Set the environment variable DOCTEST_HOME to the local copy,
##     e. g. in .bashrc:
##       export DOCTEST_HOME=/home/oliver/Dokumente/doctest-for-matlab
##
##   * GNU LilyPond, Inkscape and poppler-utils
##
##     These are used to generate or convert images for the manual.
##
##     The package repository contains only source code for the images, whereas
##     the release tarball additionally contains .PNG, .EPS and .PDF versions
##     of all images. The .PNG versions are also used in the HTML manual, which
##     is published at Octave Forge.
##

PACKAGE = $(shell grep "^Name: " DESCRIPTION | cut -f2 -d" ")
VERSION = $(shell grep "^Version: " DESCRIPTION | cut -f2 -d" ")
CC_SOURCES = $(wildcard src/*.cc)
BUILD_DIR = build
RELEASE_DIR = $(BUILD_DIR)/$(PACKAGE)-$(VERSION)
RELEASE_TARBALL = $(RELEASE_DIR).tar
RELEASE_TARBALL_COMPRESSED = $(RELEASE_TARBALL).gz
HTML_DIR = $(BUILD_DIR)/$(PACKAGE)-html
HTML_TARBALL_COMPRESSED = $(HTML_DIR).tar.gz
INSTALLED_PACKAGE = ~/octave/$(PACKAGE)-$(VERSION)/packinfo/DESCRIPTION
GENERATED_HTML = $(HTML_DIR)/$(PACKAGE)/index.html
GENERATED_NEWS = $(BUILD_DIR)/NEWS
GENERATED_COPYING = $(BUILD_DIR)/COPYING
GENERATED_IMAGE_DIR = $(BUILD_DIR)/doc/image
IMAGE_SOURCES = $(wildcard doc/image/*)
GENERATED_IMAGES = \
	$(IMAGE_SOURCES:%=$(BUILD_DIR)/%.png) \
	$(IMAGE_SOURCES:%=$(BUILD_DIR)/%.eps) \
	$(IMAGE_SOURCES:%=$(BUILD_DIR)/%.pdf)
OCT_COMPILED = $(BUILD_DIR)/.oct

OCTAVE ?= octave
MKOCTFILE ?= mkoctfile

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

dist: $(RELEASE_TARBALL_COMPRESSED)
html: $(HTML_TARBALL_COMPRESSED)
md5:  $(RELEASE_TARBALL_COMPRESSED) $(HTML_TARBALL_COMPRESSED)
	@md5sum $^

release: $(RELEASE_TARBALL_COMPRESSED) $(HTML_TARBALL_COMPRESSED) md5
	@echo "Upload @ https://sourceforge.net/p/octave/package-releases/new/"
	@echo "Execute: hg tag \"release-$(VERSION)\""

install: $(INSTALLED_PACKAGE)

clean:
	rm -rf "$(BUILD_DIR)"
	rm -f src/*.oct src/*.o
	rm -f fntests.log

$(RELEASE_TARBALL): .hg/dirstate
	@echo "Creating package release ..."
	@mkdir -p "$(BUILD_DIR)"
	@hg archive --exclude ".hg*" --exclude "Makefile" --exclude "*.sh" "$@"

$(RELEASE_TARBALL_COMPRESSED): $(RELEASE_TARBALL) $(GENERATED_NEWS) $(GENERATED_COPYING) $(GENERATED_IMAGES)
	@echo "Patching generated documentation into release tarball ..."
	@tar --append --file "$<" --transform="s!^$(BUILD_DIR)/!$(PACKAGE)-$(VERSION)/!" "$(GENERATED_NEWS)" "$(GENERATED_COPYING)" $(GENERATED_IMAGES)
	@(cd "$(BUILD_DIR)" && gzip --best -f -k "../$<")

$(INSTALLED_PACKAGE): $(RELEASE_TARBALL_COMPRESSED)
	@echo "Installing package in GNU Octave ..."
	@$(OCTAVE) --silent --eval "pkg install $<"

$(GENERATED_HTML): $(INSTALLED_PACKAGE)
	@echo "Generating HTML documentation for the package. This may take a while ..."
	@$(OCTAVE) --silent --eval \
		"pkg load generate_html; \
		 options = get_html_options ('octave-forge'); \
		 options.package_doc = 'manual.texinfo'; \
		 generate_package_html ('$(PACKAGE)', '$(HTML_DIR)', options)"

$(GENERATED_NEWS): doc/news.texinfo
	@echo "Compiling NEWS ..."
	@makeinfo --plaintext --output="$@" "$<" 

$(GENERATED_COPYING): doc/copying.texinfo
	@echo "Compiling COPYING ..."
	@makeinfo --plaintext --output="$@" "$<" 

$(GENERATED_IMAGE_DIR)/%.ly.pdf: $(GENERATED_IMAGE_DIR)/%.ly.eps
	@epstopdf "$<"

$(GENERATED_IMAGE_DIR)/%.ly.eps: $(GENERATED_IMAGE_DIR)/%.ly.png
	@touch --no-create "$@"
$(GENERATED_IMAGE_DIR)/%.ly.png: doc/image/%.ly
	@echo "Compiling $< ..."
	@mkdir -p "$(GENERATED_IMAGE_DIR)"
	@lilypond --png --output "$(GENERATED_IMAGE_DIR)/$(shell basename "$<")" --silent "$<"

$(GENERATED_IMAGE_DIR)/%.svg.png: $(GENERATED_IMAGE_DIR)/%.svg.pdf
	@pdftocairo -png -singlefile -gray -r 120 "$<" "$(BUILD_DIR)/cairo.tmp"
	@mv "$(BUILD_DIR)/cairo.tmp.png" "$@"

$(GENERATED_IMAGE_DIR)/%.svg.pdf: $(GENERATED_IMAGE_DIR)/%.svg.eps
	@touch --no-create "$@"
$(GENERATED_IMAGE_DIR)/%.svg.eps: doc/image/%.svg
	@echo "Compiling $< ..."
	@mkdir -p "$(GENERATED_IMAGE_DIR)"
	@inkscape --without-gui \
		--export-eps="$(BUILD_DIR)/$<.eps" \
		--export-pdf="$(BUILD_DIR)/$<.pdf" \
		"$<" > /dev/null

$(HTML_TARBALL_COMPRESSED): $(GENERATED_HTML)
	@tar --create --auto-compress --transform="s!^$(BUILD_DIR)/!!" --file "$@" "$(HTML_DIR)"

$(CC_SOURCES): src/Makefile
	@touch --no-create "$@"

$(OCT_COMPILED): $(CC_SOURCES)
	@echo "Compiling OCT-files ..."
	@(cd src; MKOCTFILE=$(MKOCTFILE) make)
	@mkdir -p "$(BUILD_DIR)"
	@touch "$@"

run: $(OCT_COMPILED)
	@echo "Run GNU Octave with the development version of the package"
	@$(OCTAVE) --silent --path "inst/" --path "src/"
	@echo

check: $(OCT_COMPILED)
	@echo "Testing package in GNU Octave ..."
	@$(OCTAVE) --silent --path "inst/" --path "src/" --eval "__run_test_suite__ ({'.'}, {})"
	@echo

####################################################################
## The following rule checks for errors in @example blocks within ##
## the functions' documentation strings                           ##
####################################################################

ifdef DOCTEST_HOME

check: doctest
.PHONY: doctest
doctest: $(OCT_COMPILED)
	@echo "Testing documentation strings ..."
	@$(OCTAVE) --silent --path "inst/" --path "src/" --path "$(DOCTEST_HOME)" --eval "doctest $(shell (ls inst; ls src | grep .oct) | cut -f2 -d@ | cut -f1 -d.) $(shell find doc/ -name \*.texinfo)"
	@echo

else

check: DOCTESTWARNING
.PHONY: DOCTESTWARNING
DOCTESTWARNING:
	@echo
	@echo "WARNING: doctest-for-matlab not installed properly."
	@echo "Documentation strings will not be checked."
	@echo
	@echo "Download doctest-for-matlab from https://github.com/catch22/doctest-for-matlab"
	@echo "and set the environment variable DOCTEST_HOME accordingly."
	@echo

endif

###################################################################
## The following rules are required for generation of test files ##
###################################################################

TST_SOURCES = $(wildcard test/*.itl)
TST_GENERATED_DIR = $(BUILD_DIR)/octave/native/interval
TST_GENERATED = $(TST_SOURCES:test/%.itl=$(TST_GENERATED_DIR)/%.tst)
PWD = $(shell pwd)

.PHONY: tests
tests: $(TST_GENERATED)

$(TST_GENERATED_DIR)/%.tst: test/%.itl
	@echo "Compiling $< ..."
	@(cd "$(ITF1788_HOME)/src" && python3 main.py -f "$(shell basename $<)" -c "(octave, native, interval)" -o "$(PWD)/$(BUILD_DIR)" -s "$(PWD)/test")
	@(	echo "## DO NOT EDIT!  Generated automatically from $<"; \
		echo "## by the Interval Testing Framework for IEEE 1788."; \
		echo -n "## https://github.com/nehmeier/ITF1788/tree/"; \
		echo $(shell cd "$(ITF1788_HOME)" && git log --max-count=1 | head -1 | cut -f2 -d" "); \
		cat "$@") > "$@_"
	@mv "$@_" "$@"

ifdef ITF1788_HOME

$(RELEASE_TARBALL_COMPRESSED): patch-tests
.INTERMEDIATE: patch-tests
patch-tests: $(RELEASE_TARBALL) $(TST_GENERATED) 
	@echo "Patching generated tests into release tarball ..."
	@tar --append --file "$<" --transform="s!^$(TST_GENERATED_DIR)/!$(PACKAGE)-$(VERSION)/inst/test/!" $(TST_GENERATED_DIR)/*

check: $(TST_GENERATED)

else

$(RELEASE_TARBALL_COMPRESSED): ITF1788WARNING
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
