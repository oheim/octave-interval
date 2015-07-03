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
##   * Octave package: doctest
##
##     The Octave Forge package is used to find errors in the code of
##     @example blocks from the documentation (both function documentation
##     and user manual).
##
##   * Octave package: generate_html
##
##     The Octave Forge package is used to generate the HTML documentation
##     for publication of this package on Octave Forge.
##
##   * GNU LilyPond and Inkscape
##
##     These are used to generate or convert images for the manual.
##
##     The package repository contains only source code for the images, whereas
##     the release tarball additionally contains .PNG, .EPS and .PDF versions
##     of all images. The .PNG versions are also used in the HTML manual, which
##     is published at Octave Forge.
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

PACKAGE = $(shell grep "^Name: " DESCRIPTION | cut -f2 -d" ")
VERSION = $(shell grep "^Version: " DESCRIPTION | cut -f2 -d" ")
DATE = $(shell grep "^Date: " DESCRIPTION | cut -f2 -d" ")
CC_SOURCES = $(wildcard src/*.cc)
CC_WITH_TESTS = $(shell grep --files-with-matches '^%!' $(CC_SOURCES))
BUILD_DIR = build
RELEASE_DIR = $(BUILD_DIR)/$(PACKAGE)-$(VERSION)
RELEASE_TARBALL = $(RELEASE_DIR).tar
RELEASE_TARBALL_COMPRESSED = $(RELEASE_TARBALL).gz
HTML_DIR = $(BUILD_DIR)/$(PACKAGE)-html
HTML_TARBALL_COMPRESSED = $(HTML_DIR).tar.gz
INSTALLED_PACKAGE = ~/octave/$(PACKAGE)-$(VERSION)/packinfo/DESCRIPTION
GENERATED_COPYING = $(BUILD_DIR)/COPYING
GENERATED_CITATION = $(BUILD_DIR)/CITATION
GENERATED_NEWS = $(BUILD_DIR)/NEWS
GENERATED_IMAGE_DIR = $(BUILD_DIR)/doc/image
IMAGE_SOURCES = $(wildcard doc/image/*)
GENERATED_IMAGES_EPS = $(patsubst %,$(BUILD_DIR)/%.eps,$(IMAGE_SOURCES))
GENERATED_IMAGES_PDF = $(patsubst %,$(BUILD_DIR)/%.pdf,$(IMAGE_SOURCES))
GENERATED_IMAGES_PNG = $(patsubst %,$(BUILD_DIR)/%.png,$(IMAGE_SOURCES))
GENERATED_IMAGES = $(GENERATED_IMAGES_EPS) $(GENERATED_IMAGES_PDF) $(GENERATED_IMAGES_PNG)
EXTRACTED_CC_TESTS = $(patsubst src/%.cc,$(BUILD_DIR)/inst/test/%.cc-tst,$(CC_WITH_TESTS))
GENERATED_OBJ = $(GENERATED_CITATION) $(GENERATED_COPYING) $(GENERATED_NEWS) $(GENERATED_IMAGES) $(EXTRACTED_CC_TESTS)
TAR_PATCHED = $(BUILD_DIR)/.tar
OCT_COMPILED = $(BUILD_DIR)/.oct


OCTAVE ?= octave
MKOCTFILE ?= mkoctfile -Wall

.PHONY: help dist release html run check test doctest install info clean md5

help:
	@echo
	@echo "Usage:"
	@echo "   make dist     Create $(PACKAGE)-$(VERSION).tar.gz for release"
	@echo "   make html     Create $(PACKAGE)-html.tar.gz for release"
	@echo "   make release  Create both of the above plus md5 sums"
	@echo
	@echo "   make install  Install the package in GNU Octave"
	@echo "   make check    Validate the package (w/o install)"
	@echo "   make run      Run the package in GNU Octave (w/o install)"
	@echo
	@echo "   make clean    Cleanup"
	@echo

check: doctest test
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

$(BUILD_DIR) $(GENERATED_IMAGE_DIR) $(BUILD_DIR)/inst/test:
	@mkdir -p "$@"

$(RELEASE_TARBALL): .hg/dirstate | $(BUILD_DIR)
	@echo "Creating package release ..."
	@hg archive --exclude ".hg*" --exclude "Makefile" --exclude "*.sh" "$@"
	@# build/.tar* files are used for incremental updates
	@# to the tarball and must be cleared
	@rm -f $(BUILD_DIR)/.tar*

$(RELEASE_TARBALL_COMPRESSED): $(RELEASE_TARBALL)
	@echo "Compressing release tarball ..."
	@(cd "$(BUILD_DIR)" && gzip --best -f -k "../$<")
	@touch "$@"

$(INSTALLED_PACKAGE): $(RELEASE_TARBALL_COMPRESSED)
	@echo "Installing package in GNU Octave ..."
	@$(OCTAVE) --silent --eval "pkg install $<"

## Plaintext info files are generated from GNU TexInfo sources
$(GENERATED_CITATION) $(GENERATED_COPYING) $(GENERATED_NEWS): build/%: doc/%.texinfo
	@echo "Compiling $< ..."
	@makeinfo --plaintext -D "version $(VERSION)" -D "date $(DATE)" --output="$@" "$<"

## GNU LilyPond graphics
$(GENERATED_IMAGE_DIR)/%.ly.pdf: $(GENERATED_IMAGE_DIR)/%.ly.eps
	@epstopdf "$<"
	@# The eps produced by LilyPond is quite big
	@# and can be optimized via conversion eps -> pdf -> eps
	@pdftops -eps "$@" "$<"
	@touch "$@"
$(GENERATED_IMAGE_DIR)/%.ly.png $(GENERATED_IMAGE_DIR)/%.ly.eps: doc/image/%.ly | $(GENERATED_IMAGE_DIR)
	@echo "Compiling $< ..."
	@lilypond --png --output "$(GENERATED_IMAGE_DIR)/$(shell basename "$<")" --silent "$<"

## Inkscape SVG graphics
$(GENERATED_IMAGE_DIR)/%.svg.png: $(GENERATED_IMAGE_DIR)/%.svg.pdf
	@# The output of pdftocairo has a much better quality
	@# compared to the output from inkscape --export-png.
	@pdftocairo -png -singlefile -gray -r 120 "$<" "$(BUILD_DIR)/cairo.tmp"
	@mv "$(BUILD_DIR)/cairo.tmp.png" "$@"
$(GENERATED_IMAGE_DIR)/%.svg.eps $(GENERATED_IMAGE_DIR)/%.svg.pdf: doc/image/%.svg | $(GENERATED_IMAGE_DIR)
	@echo "Compiling $< ..."
	@inkscape --without-gui \
		--export-ignore-filters \
		--export-eps="$(BUILD_DIR)/$<.eps" \
		--export-pdf="$(BUILD_DIR)/$<.pdf" \
		"$<" > /dev/null

## Octave plots
## Due to a bug with the export of patch objects in gl2ps it makes no sense
## export eps and pdf files from within Octave.
$(GENERATED_IMAGE_DIR)/%.m.png: doc/image/%.m $(OCT_COMPILED) | $(GENERATED_IMAGE_DIR)
	@echo "Compiling $< ..."
	@$(OCTAVE) --silent --path "inst/" --path "src/" --eval "source ('$<'); if (exist ('__osmesa_print__')); __print_mesa__ (gcf, '$@'); else; builtin ('print', gcf, '$@'); endif"
$(GENERATED_IMAGE_DIR)/%.m.eps: $(GENERATED_IMAGE_DIR)/%.m.png
	@convert "$<" -density 120 eps3:"$@"
$(GENERATED_IMAGE_DIR)/%.m.pdf: $(GENERATED_IMAGE_DIR)/%.m.eps
	@epstopdf --outfile="$@" "$<"

## Patch generated stuff into the release tarball
$(RELEASE_TARBALL_COMPRESSED): $(TAR_PATCHED)
$(TAR_PATCHED): $(GENERATED_OBJ) | $(RELEASE_TARBALL)
	@echo "Patching generated files into release tarball ..."
	@# `tar --update --transform` fails to update the files
	@# The following line is a workaroung that removes duplicates
	@tar --delete --file "$|" $(patsubst $(BUILD_DIR)/%,$(PACKAGE)-$(VERSION)/%,$?) 2> /dev/null || true
	@tar --update --file "$|" --transform="s!^$(BUILD_DIR)/!$(PACKAGE)-$(VERSION)/!" $?
	@touch "$@"

## HTML Documentation for Octave Forge
$(HTML_TARBALL_COMPRESSED): $(INSTALLED_PACKAGE) | $(BUILD_DIR)
	@echo "Generating HTML documentation for the package. This may take a while ..."
	@# The html generation has problems when there are leftovers from
	@# a previous run, see bug #45111. Since anything is generated
	@# from scratch anyway, there is no point in keeping the
	@# deprecated files.
	@rm -rf "$(HTML_DIR)"
	@$(OCTAVE) --silent --eval \
		"pkg load generate_html; \
		 function print (h, filename); if (exist ('__osmesa_print__')); __print_mesa__ (h, filename); else; builtin ('print', h, filename); endif; endfunction; \
		 makeinfo_program ('makeinfo -D ''version $(VERSION)'' -D octave-forge --css-include=doc/manual.css'); \
		 options = get_html_options ('octave-forge'); \
		 options.package_doc = 'manual.texinfo'; \
		 generate_package_html ('$(PACKAGE)', '$(HTML_DIR)', options)"
	@tar --create --auto-compress --transform="s!^$(BUILD_DIR)/!!" --file "$@" "$(HTML_DIR)"

## If the src/Makefile changes, recompile all oct-files
$(CC_SOURCES): src/Makefile
	@touch --no-create "$@"

## Compilation of oct-files happens in a separate Makefile,
## which is bundled in the release and will be used during
## package installation by Octave.
$(OCT_COMPILED): $(CC_SOURCES) | $(BUILD_DIR)
	@echo "Compiling OCT-files ..."
	@(cd src; MKOCTFILE="$(MKOCTFILE)" make)
	@touch "$@"

## Extract tests for oct-files. These would be lost during pkg install.
$(EXTRACTED_CC_TESTS): $(BUILD_DIR)/inst/test/%.cc-tst: src/%.cc | $(BUILD_DIR)/inst/test
	@echo "Extracting tests from $< ..."
	@rm -f "$@-t" "$@"
	@(	echo "## DO NOT EDIT!  Generated automatically from $<"; \
		grep '^%!' "$<") > "$@_"
	@mv "$@_" "$@"

## Interactive shell with the package's functions in the path
run: $(OCT_COMPILED)
	@echo "Run GNU Octave with the development version of the package"
	@$(OCTAVE) --silent --path "inst/" --path "src/"
	@echo

## Validate unit tests
test: $(OCT_COMPILED) $(EXTRACTED_CC_TESTS)
	@echo "Testing package in GNU Octave ..."
	@$(OCTAVE) --silent --path "inst/" --path "src/" \
		--eval "__run_test_suite__ ({'.'}, {})"
	@! grep '!!!!! test failed' fntests.log
	@echo

## Validate code examples
doctest: $(OCT_COMPILED)
	@echo "Testing documentation strings ..."
	@$(OCTAVE) --silent --path "inst/" --path "src/" --eval \
		"pkg load doctest; \
		 targets = '$(shell (ls inst; ls src | grep .oct) | cut -f2 -d@ | cut -f1 -d.) $(shell find doc/ -name \*.texinfo)'; \
		 targets = strsplit (targets, ' '); \
		 success = doctest (targets); \
		 exit (!success)"
	@echo

## Check the creation of the manual
## The doc/Makefile may be used by the end user
GENERATED_MANUAL_HTML = $(BUILD_DIR)/doc/manual.html
GENERATED_MANUAL_PDF = $(BUILD_DIR)/doc/manual.pdf
info: $(GENERATED_MANUAL_HTML) $(GENERATED_MANUAL_PDF)
$(GENERATED_MANUAL_HTML): doc/manual.texinfo doc/manual.css $(wildcard doc/chapter/*) | $(GENERATED_IMAGES_PNG)
	@(cd doc; \
	  VERSION=$(VERSION) \
	  make manual.html)
	@mv doc/manual.html "$@"
$(GENERATED_MANUAL_PDF): doc/manual.texinfo $(wildcard doc/chapter/*) $(GENERATED_IMAGES_PDF)
	@(cd doc; \
	  TEXI2DVI_BUILD_DIRECTORY="../$(BUILD_DIR)/doc" \
	  MAKEINFO="makeinfo -I ../$(BUILD_DIR)/doc --Xopt=--tidy" \
	  VERSION=$(VERSION) \
	  make manual.pdf)
	@mv doc/manual.pdf "$@"

###################################################################
## The following rules are required for generation of test files ##
###################################################################

TST_SOURCES = $(wildcard test/*.itl)
TST_GENERATED_DIR = $(BUILD_DIR)/octave/native/interval
TST_GENERATED = $(TST_SOURCES:test/%.itl=$(TST_GENERATED_DIR)/%.tst)
TST_PATCHED = $(BUILD_DIR)/.tar.tests
PWD = $(shell pwd)

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

test: $(TST_GENERATED)
$(RELEASE_TARBALL_COMPRESSED): $(TST_PATCHED)
$(TST_PATCHED): $(TST_GENERATED) | $(RELEASE_TARBALL)
	@echo "Patching generated tests into release tarball ..."
	@# `tar --update --transform` fails to update the files
	@# The following line is a workaroung that removes duplicates
	@tar --delete --file "$|" $(patsubst $(TST_GENERATED_DIR)/%,$(PACKAGE)-$(VERSION)/inst/test/%,$?) 2> /dev/null || true
	@tar --update --file "$|" --transform="s!^$(TST_GENERATED_DIR)/!$(PACKAGE)-$(VERSION)/inst/test/!" $?
	@touch "$@"

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
