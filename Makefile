SHELL   = /bin/sh

## Copyright 2015-2017 Oliver Heimlich
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
##     Always use the latest release of doctest for releaser preparation!
##
##   * Octave package: generate_html
##
##     The Octave Forge package is used to generate the HTML documentation
##     for publication of this package on Octave Forge.
##
##     Always use the latest release of doctest for releaser preparation!
##
##   * Inkscape
##
##     Is used to generate or convert images for the manual.
##
##     The package repository contains only source code for the images, whereas
##     the release tarball additionally contains .PNG, .EPS and .PDF versions
##     of all images. The .PNG versions are also used in the HTML manual, which
##     is published at Octave Forge.
##
##   * Zopfli
##
##     Is used to produce a smaller release tarball than is possible with gzip.
##

PACKAGE = $(shell grep "^Name: " DESCRIPTION | cut -f2 -d" ")
VERSION = $(shell grep "^Version: " DESCRIPTION | cut -f2 -d" ")
DATE = $(shell grep "^Date: " DESCRIPTION | cut -f2 -d" ")
HG_ID = $(shell hg identify --id)
HG_DATETIME_LOCAL = $(shell hg log --rev . --template {date\|isodatesec})
HG_DATETIME_UTC = $(shell date --utc --rfc-3339=seconds --date="$(HG_DATETIME_LOCAL)")
TAR_REPRODUCIBLE_OPTIONS = --mtime="$(HG_DATETIME_UTC)" --mode=a+r,g-w,o-w --owner=root --group=root --numeric-owner
H_SOURCES = $(sort $(wildcard src/*.h))
CC_SOURCES = $(sort $(wildcard src/*.cc))
CC_WITH_TESTS = $(shell grep --files-with-matches '^%!' $(CC_SOURCES))
BUILD_DIR = build
RELEASE_DIR = $(BUILD_DIR)/$(PACKAGE)-$(VERSION)
RELEASE_TARBALL = $(RELEASE_DIR).tar
RELEASE_TARBALL_COMPRESSED = $(RELEASE_TARBALL).gz
HTML_DIR = $(BUILD_DIR)/$(PACKAGE)-html
HTML_TARBALL_COMPRESSED = $(HTML_DIR).tar.gz
BUNDLED_CRLIBM_DIR = src/crlibm
INSTALLED_PACKAGE_DIR = ~/octave/$(PACKAGE)-$(VERSION)
INSTALLED_PACKAGE = $(INSTALLED_PACKAGE_DIR)/packinfo/DESCRIPTION
GENERATED_COPYING = $(BUILD_DIR)/COPYING
GENERATED_CITATION = $(BUILD_DIR)/CITATION
GENERATED_NEWS = $(BUILD_DIR)/NEWS
GENERATED_IMAGE_DIR = $(BUILD_DIR)/doc/image
GENERATED_CONFIGURE = src/configure
GENERATED_CRLIBM_AUTOMAKE = \
	$(BUNDLED_CRLIBM_DIR)/aclocal.m4 \
	$(BUNDLED_CRLIBM_DIR)/configure \
	$(BUNDLED_CRLIBM_DIR)/config.guess \
	$(BUNDLED_CRLIBM_DIR)/config.sub \
	$(BUNDLED_CRLIBM_DIR)/install-sh \
	$(BUNDLED_CRLIBM_DIR)/Makefile.in \
	$(BUNDLED_CRLIBM_DIR)/scs_lib/Makefile.in \
	$(BUNDLED_CRLIBM_DIR)/crlibm_config.h.in \
	$(BUNDLED_CRLIBM_DIR)/missing \
	$(BUNDLED_CRLIBM_DIR)/INSTALL \
	$(BUNDLED_CRLIBM_DIR)/compile
EXTRACTED_CC_TESTS = $(patsubst src/%.cc,$(BUILD_DIR)/inst/test/%.cc-tst,$(CC_WITH_TESTS))
GENERATED_OBJ = $(GENERATED_CITATION) $(GENERATED_COPYING) $(GENERATED_NEWS) $(GENERATED_IMAGES) $(GENERATED_CONFIGURE) $(GENERATED_CRLIBM_AUTOMAKE) $(EXTRACTED_CC_TESTS)
TAR_PATCHED = $(BUILD_DIR)/.tar
OCT_COMPILED = $(BUILD_DIR)/.oct

LILYPOND ?= $(shell which lilypond 2> /dev/null)
OCTAVE ?= octave
MKOCTFILE ?= mkoctfile -Wall

.PHONY: help dist release html run check test doctest install info clean bootstrap md5 id

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
id:
	@echo "Source Revision: $(HG_ID)"
	@( case "$(HG_ID)" in *+ ) \
	     echo "You have uncommitted changes!";; \
	   esac \
	)

release: $(RELEASE_TARBALL_COMPRESSED) $(HTML_TARBALL_COMPRESSED) id md5
	@echo "Upload @ https://sourceforge.net/p/octave/package-releases/new/"
	@echo "The Octave Forge admins will tag this revision after publication."

install: $(INSTALLED_PACKAGE)


## Generated Autotool files for the release tarball
CRLIBM_AUTOTOOLS_OBJ = \
	src/crlibm/aclocal.m4 \
	src/crlibm/configure \
	src/crlibm/config.guess \
	src/crlibm/config.sub \
	src/crlibm/install-sh \
	src/crlibm/Makefile.in \
	src/crlibm/scs_lib/Makefile.in \
	src/crlibm/crlibm_config.h.in \
	src/crlibm/missing \
	src/crlibm/INSTALL \
	src/crlibm/compile
DIST_CRLIBM_AUTOTOOLS_OBJ = $(patsubst %,.dist/%,$(CRLIBM_AUTOTOOLS_OBJ))
.dist/src/configure: src/configure.ac
	@echo " [AUTOTOOLS] src/"
	@mkdir -p .dist/src
	@(	cd .dist/src && \
		ln -sf ../../src/configure.ac . && \
		VERSION=$(VERSION) autoconf \
	)
.NOTPARALLEL: $(DIST_CRLIBM_AUTOTOOLS_OBJ)
$(DIST_CRLIBM_AUTOTOOLS_OBJ): src/crlibm/configure.ac src/crlibm/Makefile.am src/crlibm/scs_lib/Makefile.am
	@echo " [AUTOTOOLS] src/crlibm/"
	@mkdir -p .dist/src/crlibm/scs_lib
	@(	cd .dist/src/crlibm/scs_lib && \
		ln -sf ../../../../src/crlibm/scs_lib/Makefile.am . \
	)
	@(	cd .dist/src/crlibm && \
		ln -sf $(patsubst %,../../../%,\
			src/crlibm/configure.ac \
			src/crlibm/Makefile.am \
			src/crlibm/AUTHORS \
			src/crlibm/ChangeLog \
			src/crlibm/COPYING.LIB \
			src/crlibm/NEWS \
			src/crlibm/README) . && \
		aclocal && \
		autoheader && \
		automake --add-missing -c --ignore-deps && \
		autoconf \
	)
	@touch --no-create $(DIST_CRLIBM_AUTOTOOLS_OBJ)


## Generated graphic files for the release tarball
IMAGE_SRC = $(filter-out %animation.svg,$(wildcard doc/image/*.svg))
IMAGE_OBJ = \
	$(patsubst %,%.eps,$(IMAGE_SRC)) \
	$(patsubst %,%.pdf,$(IMAGE_SRC)) \
	$(patsubst %,%.png,$(IMAGE_SRC))
DIST_IMAGE_OBJ = $(patsubst %,.dist/%,$(IMAGE_OBJ))
.dist/doc/image/%.svg.png: .dist/doc/image/%.svg.pdf
	@# The output of pdftocairo has a much better quality
	@# compared to the output from inkscape --export-png.
	@echo " [PDFTOCAIRO] PNG $<"
	@pdftocairo -png -singlefile -transp -r 120 "$<" ".dist/doc/image/$*.svg"
.dist/doc/image/%.svg.eps: doc/image/%.svg
	@mkdir -p .dist/doc/image
	@echo " [INKSCAPE] EPS $<"
	@inkscape --without-gui \
		--export-ignore-filters \
		--export-eps="$@" \
		"$<" > /dev/null
	@# Make the build reproducible and remove timestamp metadata
	@grep --invert-match "^%% CreationDate: " "$@" > "$@_"
	@mv "$@_" "$@"
.dist/doc/image/%.svg.pdf: doc/image/%.svg
	@mkdir -p .dist/doc/image
	@echo " [INKSCAPE] PDF $<"
	@inkscape --without-gui \
		--export-ignore-filters \
		--export-pdf="$@" \
		"$<" > /dev/null


## Generated text files for the release tarball
TEXT_OBJ = \
	COPYING \
	CITATION \
	NEWS
DIST_TEXT_OBJ = $(patsubst %,.dist/%,$(TEXT_OBJ))
.dist/%: doc/%.texinfo
	@echo " [MAKEINFO] $<"
	@mkdir -p .dist
	@makeinfo --plaintext -D "version $(VERSION)" -D "date $(DATE)" --output="$@" "$<"


## For the release tarball, we can take most files from version control and
## exclude:
##  - .hgignore and .hgtags
##  - some maintainer scripts
##  - crlibm test code (it is already included in crlibm.mat
##    and would take a lot of space)
## In addition, generated files are patched into the release tarball.  Since
## hg and tar are very fast, we can simply recreate the tarball from scratch.
.dist/$(PACKAGE)-$(VERSION).tar: .hg/dirstate .dist/src/configure $(DIST_CRLIBM_AUTOTOOLS_OBJ) $(DIST_IMAGE_OBJ) $(DIST_TEXT_OBJ)
	@echo " [HG] archive"
	@hg archive --exclude ".hg*" --exclude "Makefile" --exclude "*.sh" --exclude "src/crlibm/tests" "$@"
	@# Make tries to re-run automake on the target system (during installation
	@# of the Octave package) if automake artefacts are older than their source
	@# files.  Prevent this by applying the timestamp of the source code
	@# revision, which is the same that is used by “hg archive”.
	@echo " [TAR] update"
	@tar $(TAR_REPRODUCIBLE_OPTIONS) --update --file "$@" --transform="s!^.dist/!$(PACKAGE)-$(VERSION)/!" $(wordlist 2,$(words $^),$^)


clean:
	make -C src clean
	rm -rf "$(BUILD_DIR)"
	rm -rf .dist
	rm -f fntests.log

$(BUILD_DIR) $(GENERATED_IMAGE_DIR) $(BUILD_DIR)/inst $(BUILD_DIR)/inst/test:
	@mkdir -p "$@"

$(RELEASE_TARBALL): .hg/dirstate | $(BUILD_DIR)
	@echo "Creating package release ..."
	@hg archive --exclude ".hg*" --exclude "Makefile" --exclude "*.sh" --exclude "src/crlibm/tests" "$@"
	@# build/.tar* files are used for incremental updates
	@# to the tarball and must be cleared
	@rm -f $(BUILD_DIR)/.tar*

$(RELEASE_TARBALL_COMPRESSED): $(RELEASE_TARBALL)
	@echo "Compressing release tarball ..."
	@(cd "$(BUILD_DIR)" && zopfli "../$<" || gzip --best -f -k "../$<")
	@touch "$@"

$(INSTALLED_PACKAGE): $(RELEASE_TARBALL)
	@echo "Installing package in GNU Octave ..."
	@$(OCTAVE) --no-gui --silent --eval "pkg install $<"


## GNU LilyPond graphics
## This is an exotic dependency for an Octave package, so the generated SVG
## is under version control and only gets recreated when LilyPond is installed.
ifneq ($(LILYPOND),)
doc/image/%.svg: doc/image/%.ly
	@echo " [LILYPOND] $< ..."
	@# .ly -> .eps
	@$(LILYPOND) --ps --output "$(BUILD_DIR)/$<" --silent "$<"
	@# .eps -> .pdf (with size optimizations)
	@epstopdf "$(BUILD_DIR)/$<.eps"
	@# .pdf -> .ps (convert font glyphs to outline shapes)
	@gs -q -o "$(BUILD_DIR))/$<.ps" -dNOCACHE -sDEVICE=pswrite "$(BUILD_DIR)/$<.pdf"
	@# .ps -> .svg
	@inkscape --without-gui --export-ignore-filters --export-plain-svg="$@" "$(BUILD_DIR)/$<.ps"
endif

## Patch generated stuff into the release tarball
$(RELEASE_TARBALL_COMPRESSED): $(TAR_PATCHED)
$(INSTALLED_PACKAGE): $(TAR_PATCHED)
$(TAR_PATCHED): $(GENERATED_OBJ) | $(RELEASE_TARBALL)
	@echo "Patching generated files into release tarball ..."
	@# `tar --update --transform` fails to update the files
	@# The following line is a workaroung that removes duplicates
	@tar --delete --file "$|" $(patsubst $(BUILD_DIR)/%,$(PACKAGE)-$(VERSION)/%,$?) 2> /dev/null || true
	@# make tries to re-run automake on the target system (during installation
	@# of the Octave package) if automake artefacts are older than their source
	@# files.  Prevent this by applying the timestamp of the source code
	@# revision, which is the same that is used by “hg archive”.
	@tar $(TAR_REPRODUCIBLE_OPTIONS) --update --file "$|" --transform="s!^$(BUILD_DIR)/!$(PACKAGE)-$(VERSION)/!" --transform="s!^src/!$(PACKAGE)-$(VERSION)/src/!" $?
	@touch "$@"

## HTML Documentation for Octave Forge
$(HTML_TARBALL_COMPRESSED): $(INSTALLED_PACKAGE) | $(BUILD_DIR)
	@# Compile images from m-file scripts,
	@# which are not shipped in the release tarball
	@OCTAVE="$(OCTAVE)" make --directory="$(INSTALLED_PACKAGE_DIR)/doc" images
	@echo "Generating HTML documentation for the package. This may take a while ..."
	@# 1. Load the generate_html package
	@# 2. Set fonts for demo plots and use off-screen rendering
	@# 3. Make the use of random values in demos reproducible between builds
	@# 4. Specify path to package manual
	@# 5. Use custom CSS and global version number
	@#    (only affects package manual, not function reference)
	@# 6. Run the generation
	@$(OCTAVE) --no-gui --silent \
		--eval "pkg load generate_html;" \
		--eval "set (0, 'defaultaxesfontname', 'Fantasque Sans Mono');" \
		--eval "set (0, 'defaulttextfontname', 'Roboto Condensed');" \
		--eval "set (0, 'defaultfigurevisible', 'off');" \
		--eval "rand ('state', double ('reproducible')');" \
		--eval "options = get_html_options ('octave-forge');" \
		--eval "options.package_doc = 'manual.texinfo';" \
		--eval "options.package_doc_options = '-D ''version $(VERSION)'' -D octave-forge --set-customization-variable ''TOP_NODE_UP_URL ../index.html'' --set-customization-variable ''PRE_BODY_CLOSE <div id="sf_logo"><a href=\"https://sourceforge.net/\"><img width=\"88\" height=\"31\" style=\"border:0\" alt=\"Sourceforge.net Logo\" src=\"//sourceforge.net/sflogo.php?group_id=2888&amp;type=1\" /></a></div>'' --css-ref=manual.css';" \
		--eval "generate_package_html ('$(PACKAGE)', '$(HTML_DIR)', options)"
	@# Documentation will be put on a webserver,
	@# where .svgz files can save bandwidth and CPU time.
	@# Locally this doesn't work so well, see https://bugzilla.mozilla.org/show_bug.cgi?id=52282
	@(cd $(HTML_DIR)/$(PACKAGE)/package_doc/image/; \
		((zopfli *.svg && rm -f *.svg) || gzip --best -f *.svg); \
		rename 's!\.svg\.gz!.svgz!' *.svg.gz)
	@(cd $(HTML_DIR)/$(PACKAGE)/package_doc/; \
		sed -i 's!"\(image/[^"]*\.svg\)"!"\1z"!g' *.html)
	@tar --create --auto-compress --transform="s!^$(BUILD_DIR)/!!" --file "$@" "$(HTML_DIR)"

## If the src/Makefile changes, recompile all oct-files
$(CC_SOURCES): src/Makefile
	@touch --no-create "$@"

## Compilation of oct-files happens in a separate Makefile,
## which is bundled in the release and will be used during
## package installation by Octave.
$(OCT_COMPILED): $(CC_SOURCES) $(H_SOURCES) | $(BUILD_DIR) $(GENERATED_CRLIBM_AUTOMAKE)
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
run: $(OCT_COMPILED) $(EXTRACTED_CC_TESTS)
	@echo "Run GNU Octave with the development version of the package"
	@$(OCTAVE) --no-gui --silent --path "inst/" --path "src/"
	@echo

## Validate code examples
doctest: doctest-manual doctest-docstrings
.PHONY: doctest-manual doctest-docstrings
doctest-manual: $(OCT_COMPILED)
	@# Workaround for OctSymPy issue 273, we must pre-initialize the package
	@# Otherwise, it will make the doctests fail
	@echo "Testing package manual ..."
	@$(OCTAVE) --no-gui --silent --path "inst/" --path "src/" --eval \
		"pkg load doctest; \
		 pkg load symbolic; warning ('off', 'OctSymPy:function_handle:nocodegen'); sym ('x'); \
		 set (0, 'defaultfigurevisible', 'off'); \
		 makeinfo_program (cstrcat (makeinfo_program (), ' -I doc/')); \
		 targets = '$(shell find doc/ -name "*.texinfo")'; \
		 targets = strsplit (targets, ' '); \
		 success = doctest (targets); \
		 exit (!success)"
doctest-docstrings: $(OCT_COMPILED)
	@echo "Testing documentation strings ..."
	@$(OCTAVE) --no-gui --silent --path "inst/" --path "src/" --eval \
		"pkg load doctest; \
		 set (0, 'defaultfigurevisible', 'off'); \
		 targets = '@infsup @infsupdec $(shell find inst/ src/ -maxdepth 1 -regex ".*\\.\\(m\\|oct\\)" -printf "%f\\n" | cut -f1 -d.)'; \
		 targets = strsplit (targets, ' '); \
		 success = doctest (targets); \
		 exit (!success)"

## Check the creation of the manual
## The doc/Makefile may be used by the end user
GENERATED_MANUAL_HTML = $(BUILD_DIR)/doc/manual.html
GENERATED_MANUAL_PDF = $(BUILD_DIR)/doc/manual.pdf
info: $(GENERATED_MANUAL_HTML) $(GENERATED_MANUAL_PDF)
$(GENERATED_MANUAL_HTML): doc/manual.texinfo doc/manual.css $(wildcard doc/chapter/*) $(wildcard doc/image/*.texinfo) | $(GENERATED_IMAGES_PNG) $(INSTALLED_PACKAGE)
	@cp -f --update $(BUILD_DIR)/doc/image/*.m.png doc/image/ || true
	@(cd doc; \
	  VERSION=$(VERSION) \
	  OCTAVE="$(OCTAVE)" \
	  $(MAKE) manual.html)
	@mv doc/image/*.m.png "$(BUILD_DIR)/doc/image/"
	@cp -f --update doc/image/*.svg "$(BUILD_DIR)/doc/image/"
	@mv doc/manual.html "$@"
$(GENERATED_MANUAL_PDF): doc/manual.texinfo $(wildcard doc/chapter/*) $(wildcard doc/image/*.texinfo) $(GENERATED_IMAGES_PDF) $(INSTALLED_PACKAGE)
	@cp -f --update $(BUILD_DIR)/doc/image/*.m.png doc/image/ || true
	@(cd doc; \
	  TEXI2DVI_BUILD_DIRECTORY="../$(BUILD_DIR)/doc" \
	  MAKEINFO="makeinfo -I ../$(BUILD_DIR)/doc --Xopt=--tidy" \
	  VERSION=$(VERSION) \
	  OCTAVE="$(OCTAVE)" \
	  $(MAKE) manual.pdf)
	@mv doc/image/*.m.png "$(BUILD_DIR)/doc/image/"
	@mv doc/manual.pdf "$@"

## Push the new release to Debian
## (inspired by https://xkcd.com/1597/ because I always forget the required commands)
.PHONY: debian
DEBIAN_WORKSPACE_ROOT = ../Debian
debian:
	cp "$(RELEASE_TARBALL_COMPRESSED)" "$(DEBIAN_WORKSPACE_ROOT)/octave-$(PACKAGE)_$(VERSION).orig.tar.gz"
	(cd $(DEBIAN_WORKSPACE_ROOT)/octave-$(PACKAGE) && \
	 gbp import-orig ../octave-$(PACKAGE)_$(VERSION).orig.tar.gz --pristine-tar)

## Run built-in self tests (BISTs)
test: $(OCT_COMPILED)
	@echo "Testing built-in self tests (BISTs) ..."
	@$(OCTAVE) --no-gui --silent --path "inst/" --path "src/" \
		--eval 'success = true;' \
		--eval 'for file = {dir("./src/*.cc").name}, success &= test (file{1}, "quiet", stdout); endfor;' \
		--eval 'for file = {dir("./inst/*.m").name}, success &= test (file{1}, "quiet", stdout); endfor;' \
		--eval 'for file = {dir("./inst/test/*.tst").name}, success &= test (strcat ("test/", file{1}), "quiet", stdout); endfor;' \
		--eval 'for file = {dir("./inst/@infsup/*.m").name}, success &= test (strcat ("@infsup/", file{1}), "quiet", stdout); endfor;' \
		--eval 'for file = {dir("./inst/@infsupdec/*.m").name}, success &= test (strcat ("@infsupdec/", file{1}), "quiet", stdout); endfor;' \
		--eval 'exit (not (success));'
