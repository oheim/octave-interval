SHELL   = /bin/sh

## Copyright 2015-2016 Oliver Heimlich
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
INSTALLED_PACKAGE_DIR = ~/octave/$(PACKAGE)-$(VERSION)
INSTALLED_PACKAGE = $(INSTALLED_PACKAGE_DIR)/packinfo/DESCRIPTION
GENERATED_COPYING = $(BUILD_DIR)/COPYING
GENERATED_CITATION = $(BUILD_DIR)/CITATION
GENERATED_NEWS = $(BUILD_DIR)/NEWS
GENERATED_IMAGE_DIR = $(BUILD_DIR)/doc/image
IMAGE_SOURCES = \
	doc/image/cameleon-start-end.svg \
	doc/image/cameleon-transition.svg \
	doc/image/inverse-power.svg \
	doc/image/octave-interval.ly
GENERATED_IMAGES_EPS = $(patsubst %,$(BUILD_DIR)/%.eps,$(IMAGE_SOURCES))
GENERATED_IMAGES_PDF = $(patsubst %,$(BUILD_DIR)/%.pdf,$(IMAGE_SOURCES))
GENERATED_IMAGES_PNG = $(patsubst %,$(BUILD_DIR)/%.png,$(IMAGE_SOURCES))
GENERATED_IMAGES = $(GENERATED_IMAGES_EPS) $(GENERATED_IMAGES_PDF) $(GENERATED_IMAGES_PNG)
GENERATED_CRLIBM_AUTOMAKE = \
	src/crlibm/aclocal.m4 \
	src/crlibm/configure \
	src/crlibm/config.guess \
	src/crlibm/config.sub \
	src/crlibm/install-sh \
	src/crlibm/Makefile.in \
	src/crlibm/scs_lib/Makefile.in \
	src/crlibm/crlibm_config.h.in \
	src/crlibm/depcomp \
	src/crlibm/missing \
	src/crlibm/INSTALL \
	src/crlibm/compile
EXTRACTED_CC_TESTS = $(patsubst src/%.cc,$(BUILD_DIR)/inst/test/%.cc-tst,$(CC_WITH_TESTS))
GENERATED_OBJ = $(GENERATED_CITATION) $(GENERATED_COPYING) $(GENERATED_NEWS) $(GENERATED_IMAGES) $(GENERATED_CRLIBM_AUTOMAKE) $(EXTRACTED_CC_TESTS)
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
	make -C src clean
	rm -rf "$(BUILD_DIR)"
	rm -f fntests.log

$(BUILD_DIR) $(GENERATED_IMAGE_DIR) $(BUILD_DIR)/inst/test:
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
	@pdftocairo -png -singlefile -transp -r 120 "$<" "$(BUILD_DIR)/cairo.tmp"
	@mv "$(BUILD_DIR)/cairo.tmp.png" "$@"
$(GENERATED_IMAGE_DIR)/%.svg.eps $(GENERATED_IMAGE_DIR)/%.svg.pdf: doc/image/%.svg | $(GENERATED_IMAGE_DIR)
	@echo "Compiling $< ..."
	@inkscape --without-gui \
		--export-ignore-filters \
		--export-eps="$(BUILD_DIR)/$<.eps" \
		--export-pdf="$(BUILD_DIR)/$<.pdf" \
		"$<" > /dev/null

$(GENERATED_CRLIBM_AUTOMAKE):
	(cd src/crlibm && aclocal && autoheader && autoconf && automake --add-missing -c --ignore-deps && autoconf)

## Patch generated stuff into the release tarball
$(RELEASE_TARBALL_COMPRESSED): $(TAR_PATCHED)
$(INSTALLED_PACKAGE): $(TAR_PATCHED)
$(TAR_PATCHED): $(GENERATED_OBJ) | $(RELEASE_TARBALL)
	@echo "Patching generated files into release tarball ..."
	@# make tries to re-run automake on the target system (during installation
	@# of the Octave package) if automake artefacts are older than their source
	@# files.  Prevent this by touching these files, so they will be newer than
	@# the files that have been added by “hg archive”.
	@touch $(GENERATED_CRLIBM_AUTOMAKE)
	@# `tar --update --transform` fails to update the files
	@# The following line is a workaroung that removes duplicates
	@tar --delete --file "$|" $(patsubst $(BUILD_DIR)/%,$(PACKAGE)-$(VERSION)/%,$?) 2> /dev/null || true
	@tar --update --file "$|" --transform="s!^$(BUILD_DIR)/!$(PACKAGE)-$(VERSION)/!" --transform="s!^src/!$(PACKAGE)-$(VERSION)/src/!" $?
	@touch "$@"

## HTML Documentation for Octave Forge
$(HTML_TARBALL_COMPRESSED): $(INSTALLED_PACKAGE) | $(BUILD_DIR)
	@# Compile images from m-file scripts,
	@# which are not shipped in the release tarball
	@OCTAVE="$(OCTAVE)" make --directory="$(INSTALLED_PACKAGE_DIR)/doc" images
	@echo "Generating HTML documentation for the package. This may take a while ..."
	@# 1. Load the generate_html package
	@# 2. Replace builtin print function because of various
	@#    bugs #44181, #45104, #45137
	@# 3. Set fonts for demo plots and use off-screen rendering
	@# 4. Make the use of random values in demos reproducible between builds
	@# 5. Specify path to package manual
	@# 6. Use custom CSS and global version number
	@#    (only affects package manual, not function reference)
	@# 7. Run the generation
	@$(OCTAVE) --no-gui --silent \
		--eval "pkg load generate_html;" \
		--eval "function print (h, filename); __print_mesa__ (h, filename); endfunction;" \
		--eval "set (0, 'defaultaxesfontname', 'Fantasque Sans Mono');" \
		--eval "set (0, 'defaulttextfontname', 'Roboto Condensed');" \
		--eval "set (0, 'defaultfigurevisible', 'off');" \
		--eval "rand ('state', double ('reproducible')');" \
		--eval "options = get_html_options ('octave-forge');" \
		--eval "options.package_doc = 'manual.texinfo';" \
		--eval "options.package_doc_options = '-D ''version $(VERSION)'' -D octave-forge --set-customization-variable ''TOP_NODE_UP_URL ../index.html'' --set-customization-variable ''PRE_BODY_CLOSE <div id="sf_logo"><a href=\"http://sourceforge.net/\"><img width=\"88\" height=\"31\" style=\"border:0\" alt=\"Sourceforge.net Logo\" src=\"http://sourceforge.net/sflogo.php?group_id=2888&amp;type=1\" /></a></div>'' --css-ref=''https://www.gnu.org/software/octave/doc/interpreter/octave.css'' --css-ref=manual.css';" \
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
$(OCT_COMPILED): $(CC_SOURCES) | $(BUILD_DIR) $(GENERATED_CRLIBM_AUTOMAKE)
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
	@$(OCTAVE) --no-gui --silent --path "inst/" --path "src/"
	@echo

## Validate unit tests
test: $(OCT_COMPILED) $(EXTRACTED_CC_TESTS)
	@echo "Testing package in GNU Octave ..."
	@$(OCTAVE) --no-gui --silent --path "inst/" --path "src/" \
		--eval "__run_test_suite__ ({'.'}, {})"
	@! grep '!!!!! test failed' fntests.log
	@echo

## Validate code examples
doctest: $(OCT_COMPILED)
	@# Workaround for OctSymPy issue 273, we must pre-initialize the package
	@# Otherwise, it will make the doctests fail
	@echo "Testing documentation strings ..."
	@$(OCTAVE) --no-gui --silent --path "inst/" --path "src/" --eval \
		"pkg load doctest; \
		 pkg load symbolic; warning ('off', 'OctSymPy:function_handle:nocodegen'); sym ('x'); \
		 set (0, 'defaultfigurevisible', 'off'); \
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
$(GENERATED_MANUAL_HTML): doc/manual.texinfo doc/manual.css $(wildcard doc/chapter/*) $(wildcard doc/image/*.texinfo) | $(GENERATED_IMAGES_PNG)
	@cp -f --update $(BUILD_DIR)/doc/image/*.m.png doc/image/ || true
	@(cd doc; \
	  VERSION=$(VERSION) \
	  make manual.html)
	@mv doc/image/*.m.png "$(BUILD_DIR)/doc/image/"
	@cp -f --update doc/image/*.svg "$(BUILD_DIR)/doc/image/"
	@mv doc/manual.html "$@"
$(GENERATED_MANUAL_PDF): doc/manual.texinfo $(wildcard doc/chapter/*) $(wildcard doc/image/*.texinfo) $(GENERATED_IMAGES_PDF)
	@cp -f --update $(BUILD_DIR)/doc/image/*.m.png doc/image/ || true
	@(cd doc; \
	  TEXI2DVI_BUILD_DIRECTORY="../$(BUILD_DIR)/doc" \
	  MAKEINFO="makeinfo -I ../$(BUILD_DIR)/doc --Xopt=--tidy" \
	  VERSION=$(VERSION) \
	  make manual.pdf)
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

###################################################################
## The following rules are required for generation of test files ##
###################################################################

TST_SOURCES = $(wildcard test/*.itl)
TST_GENERATED_DIR = $(BUILD_DIR)/octave/native/interval
TST_GENERATED = $(TST_SOURCES:test/%.itl=$(TST_GENERATED_DIR)/%.tst)
TST_PATCHED = $(BUILD_DIR)/.tar.tests

$(TST_GENERATED_DIR)/%.tst: test/%.itl
	@echo "Compiling $< ..."
	@PYTHONPATH="$(ITF1788_HOME)" python3 -m itf1788 -f "$(shell basename $<)" -c "(octave, native, interval)" -o "$(BUILD_DIR)" -s "test"
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
