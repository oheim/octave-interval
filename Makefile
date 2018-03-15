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

OCTAVE ?= octave
MKOCTFILE ?= mkoctfile -Wall
ZOPFLI ?= $(shell which zopfli 2> /dev/null)

PACKAGE = $(shell grep "^Name: " DESCRIPTION | cut -f2 -d" ")
VERSION = $(shell grep "^Version: " DESCRIPTION | cut -f2 -d" ")
DATE = $(shell grep "^Date: " DESCRIPTION | cut -f2 -d" ")
HG_ID = $(shell hg identify --id)

HG_DATETIME_LOCAL = $(shell hg log --rev . --template {date\|isodatesec})
HG_DATETIME_UTC = $(shell date --utc --rfc-3339=seconds --date="$(HG_DATETIME_LOCAL)")
TAR_REPRODUCIBLE_OPTIONS = --mtime="$(HG_DATETIME_UTC)" --mode=a+r,g-w,o-w --owner=root --group=root --numeric-owner

OCTAVE_REPRODUCIBLE_OPTIONS = \
	--norc \
	--silent \
	--no-history \
	--no-gui \
	--eval "rand ('state', double ('reproducible')');"

OCTAVE_INSTALL_MISSING = \
	$(OCTAVE) $(OCTAVE_REPRODUCIBLE_OPTIONS) \
		--eval "if isempty (pkg ('list', 'PKG')), \
			disp (' [OCTAVE] pkg install PKG'); \
			pkg install -forge -local PKG; \
			endif;"

.PHONY: help
help:
	@echo
	@echo "Usage:"
	@echo "   make dist     Create $(PACKAGE)-$(VERSION).tar.gz for release"
	@echo "   make html     Create $(PACKAGE)-html.tar.gz for release"
	@echo "   make release  Create both of the above plus md5 sums"
	@echo
	@echo "   make install  Install the release in GNU Octave"
	@echo "   make check    Validate the package (w/o install)"
	@echo "   make run      Run the package in GNU Octave (w/o install)"
	@echo
	@echo "   make clean    Cleanup"
	@echo

.PHONY: clean
clean:
	$(RM) -r .build .dist .html

##
## PART A: Produce the release tarball
##
## This happens in a temporary directory ./.dist/
##

## Generated Autotool files
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

## Generated graphic files
IMAGE_SRC = $(filter-out %animation.svg,$(wildcard doc/image/*.svg))
IMAGE_OBJ = \
	$(patsubst %,%.eps,$(IMAGE_SRC)) \
	$(patsubst %,%.pdf,$(IMAGE_SRC)) \
	$(patsubst %,%.png,$(IMAGE_SRC))
DIST_IMAGE_OBJ = $(patsubst %,.dist/%,$(IMAGE_OBJ))
.dist/doc/image/%.svg.png: .dist/doc/image/%.svg.pdf
	@# The output of pdftocairo has a much better quality
	@# compared to the output from inkscape --export-png.
	@echo " [PDFTOCAIRO] $<"
	@pdftocairo -png -singlefile -transp -r 120 "$<" ".dist/doc/image/$*.svg"
.dist/doc/image/%.svg.eps: doc/image/%.svg
	@mkdir -p .dist/doc/image
	@echo " [INKSCAPE --export-eps] $<"
	@inkscape --without-gui \
		--export-ignore-filters \
		--export-eps="$@" \
		"$<" > /dev/null
	@# Make the build reproducible and remove timestamp metadata
	@grep --invert-match "^%% CreationDate: " "$@" > "$@_"
	@mv "$@_" "$@"
.dist/doc/image/%.svg.pdf: doc/image/%.svg
	@mkdir -p .dist/doc/image
	@echo " [INKSCAPE --export-pdf] $<"
	@inkscape --without-gui \
		--export-ignore-filters \
		--export-pdf="$@" \
		"$<" > /dev/null

## Generated text files
TEXT_OBJ = COPYING CITATION NEWS
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
	@echo " [TAR --update] $@"
	@tar $(TAR_REPRODUCIBLE_OPTIONS) --update --file "$@" --transform="s!^.dist/!$(PACKAGE)-$(VERSION)/!" $(wordlist 2,$(words $^),$^)

## Compress the tarball for smaller download size.
## Zopfli can create smaller files that gzip.
.PHONY: dist
dist: .dist/$(PACKAGE)-$(VERSION).tar.gz
.dist/$(PACKAGE)-$(VERSION).tar.gz: .dist/$(PACKAGE)-$(VERSION).tar
ifneq ($(ZOPFLI),)
%.gz: %
	@echo " [ZOPFLI] $<"
	@$(ZOPFLI) --i10 "$<"
else
%.gz: %
	@echo " [GZIP] $<"
	@gzip --best -f -k "$<"
	@touch "$@"
endif

##
## Part B: Create HTML documentation for publication on Octave Forge
##
## Installs the package in Octave and partly happens in the user's pkg dir,
## the result is put in a temporary directory ./.html/
##

## Install the release tarball in Octave
OCTAVE_PKG_PREFIX = $(HOME)/octave
INSTALLED_PACKAGE = $(OCTAVE_PKG_PREFIX)/$(PACKAGE)-$(VERSION)/packinfo/DESCRIPTION
.PHONY: install
install: $(INSTALLED_PACKAGE)
$(INSTALLED_PACKAGE): .dist/$(PACKAGE)-$(VERSION).tar
	@echo " [OCTAVE] pkg install $(PACKAGE)"
	@$(OCTAVE) $(OCTAVE_REPRODUCIBLE_OPTIONS) \
		--eval "pkg install -local $<"

## Create HTML Documentation from scratch
.PHONY: html
html: .html/$(PACKAGE)-html.tar.gz
.html/$(PACKAGE)-html.tar.gz: $(INSTALLED_PACKAGE)
	@$(subst PKG,generate_html,$(OCTAVE_INSTALL_MISSING))
	@# Compile images from m-file scripts in the installed package.
	@# These are not shipped in the release tarball.
	@echo " [MAKE] doc/images/*.m"
	@OCTAVE="$(OCTAVE) $(subst ",\",$(OCTAVE_REPRODUCIBLE_OPTIONS))" $(MAKE) --directory="$(OCTAVE_PKG_PREFIX)/$(PACKAGE)-$(VERSION)/doc" images
	@# Create manual and function reference
	@#  - Use off-screen rendering (for demos)
	@#  - Specify path to package manual
	@#  - Use custom CSS and global version number
	@#    (only affects package manual, not function reference)
	@echo " [OCTAVE] generate_package_html"
	@$(OCTAVE) $(OCTAVE_REPRODUCIBLE_OPTIONS) \
		--eval "pkg load generate_html;" \
		--eval "set (0, 'defaultfigurevisible', 'off');" \
		--eval "options = get_html_options ('octave-forge');" \
		--eval "options.package_doc = 'manual.texinfo';" \
		--eval "options.package_doc_options = '-D ''version $(VERSION)'' -D octave-forge --set-customization-variable ''TOP_NODE_UP_URL ../index.html'' --set-customization-variable ''PRE_BODY_CLOSE <div id="sf_logo"><a href=\"https://sourceforge.net/\"><img width=\"120\" height=\"30\" style=\"border:0\" alt=\"Sourceforge.net Logo\" src=\"https://sourceforge.net/sflogo.php?group_id=2888&amp;type=13\" /></a></div>'' --css-ref=manual.css';" \
		--eval "generate_package_html ('$(PACKAGE)', '.html', options)"
	@# Documentation will be put on a webserver,
	@# where .svgz files can save bandwidth and CPU time.
	@# Locally this doesn't work so well, see https://bugzilla.mozilla.org/show_bug.cgi?id=52282
	@echo " [GZIP] package_doc/image/*.svg"
	@(	cd .html/$(PACKAGE)/package_doc/image/; \
		gzip --best -f *.svg; \
		rename -f 's!\.svg\.gz!.svgz!' *.svg.gz)
	@echo " [SED] package_doc/*.html"
	@(cd .html/$(PACKAGE)/package_doc/; \
		sed -i 's!"\(image/[^"]*\.svg\)"!"\1z"!g' *.html)
	@echo " [TAR --create] .html/$(PACKAGE)/"
	@tar --create --auto-compress --transform="s!^.html/!!" --file "$@" .html/$(PACKAGE)/

## The release consists of the tarball from part A and the HTML documentation
## for Octave Forge.  Revision numbers and hash values are used to tag and
## verify the upload.
.PHONY: release
release: .dist/$(PACKAGE)-$(VERSION).tar.gz .html/$(PACKAGE)-html.tar.gz
	@echo "Source Revision: $(HG_ID)"
	@( case "$(HG_ID)" in *+ ) \
	     echo "You have uncommitted changes!";; \
	   esac \
	)
	@md5sum $^
	@echo "Upload @ https://sourceforge.net/p/octave/package-releases/new/"
	@echo "The Octave Forge admins will tag this revision after publication."

##
## Part C: (Interactive) tests during development
##
## There is no need to install the package.  Generated files (see part A) and
## compiled OCT files can be rebuild incrementally, which is fast.  OCT files
## are compiled in a temporary directory .build, from where they can be loaded.
##

## Mirror generated .dist files for compilation in .build
.build/configure: .build/%: .dist/src/%
	@mkdir -p .build
	@ln -sf ../$< $@
$(patsubst src/%,.build/%,$(filter-out src/crlibm/scs_lib/%,$(CRLIBM_AUTOTOOLS_OBJ))): .build/%: .dist/src/%
	@mkdir -p .build/crlibm
	@ln -sf ../../$< $@
.build/crlibm/scs_lib/Makefile.in: .build/%: .dist/src/%
	@mkdir -p .build/crlibm/scs_lib
	@ln -sf ../../../$< $@

## If the src/Makefile changes, recompile all oct-files
$(wildcard src/*.cc): src/Makefile
	@touch --no-create "$@"

## Mirror any workspace src/* files in .build and compile OCT files
OCT_COMPILED = .build/.oct
$(OCT_COMPILED): $(wildcard src/*) .build/configure $(patsubst src/%,.build/%,$(CRLIBM_AUTOTOOLS_OBJ))
	@ln -sf $(patsubst %,../%,$(filter-out src/crlibm,$(wildcard src/*))) .build/
	@ln -sf $(patsubst %,../../%,$(filter-out src/crlibm/scs_lib,$(wildcard src/crlibm/*))) .build/crlibm/
	@ln -sf $(patsubst %,../../../%,$(wildcard src/crlibm/scs_lib/*)) .build/crlibm/scs_lib/
	@echo " [MAKE] src"
	@OCTAVE="$(OCTAVE) $(subst ",\",$(OCTAVE_REPRODUCIBLE_OPTIONS))" MKOCTFILE="$(MKOCTFILE)" $(MAKE) --directory=.build
	@touch $@

## Octave parameters to make M files and compiled OCT files available
OCTAVE_WORKSPACE_PATH = --path "inst/" --path ".build/"

## Interactive shell with the current workspace functions in the path
.PHONY: run
run: $(OCT_COMPILED)
	@$(OCTAVE) $(OCTAVE_WORKSPACE_PATH) --no-gui --silent
	@echo

## Run built-in self tests (BISTs)
.PHONY: test
test: $(OCT_COMPILED)
	@echo " [OCTAVE] test"
	@$(OCTAVE) $(OCTAVE_REPRODUCIBLE_OPTIONS) $(OCTAVE_WORKSPACE_PATH) \
		--eval 'success = true;' \
		--eval 'for file = {dir("./src/*.cc").name}, success &= test (file{1}, "quiet", stdout); endfor;' \
		--eval 'for file = {dir("./inst/*.m").name}, success &= test (file{1}, "quiet", stdout); endfor;' \
		--eval 'for file = {dir("./inst/test/*.tst").name}, success &= test (strcat ("test/", file{1}), "quiet", stdout); endfor;' \
		--eval 'for file = {dir("./inst/@infsup/*.m").name}, success &= test (strcat ("@infsup/", file{1}), "quiet", stdout); endfor;' \
		--eval 'for file = {dir("./inst/@infsupdec/*.m").name}, success &= test (strcat ("@infsupdec/", file{1}), "quiet", stdout); endfor;' \
		--eval 'exit (not (success));'

## Validate code examples from the package manual.
## Workaround for OctSymPy issue 273, we must pre-initialize the package.
## Otherwise, it will make the doctests fail.
.PHONY: doctest-manual
doctest-manual: $(OCT_COMPILED)
	@$(subst PKG,doctest,$(OCTAVE_INSTALL_MISSING:PKG=doctest))
	@$(subst PKG,symbolic,$(OCTAVE_INSTALL_MISSING))
	@echo " [OCTAVE] doctest doc/"
	@$(OCTAVE) $(OCTAVE_REPRODUCIBLE_OPTIONS) $(OCTAVE_WORKSPACE_PATH) \
		--eval \
		"pkg load doctest; \
		 pkg load symbolic; warning ('off', 'OctSymPy:function_handle:nocodegen'); sym ('x'); \
		 set (0, 'defaultfigurevisible', 'off'); \
		 makeinfo_program (cstrcat (makeinfo_program (), ' -I doc/')); \
		 targets = '$(shell find doc/ -name "*.texinfo")'; \
		 targets = strsplit (targets, ' '); \
		 success = doctest (targets); \
		 exit (!success)"

## Validate code examples from documentation strings.
.PHONY: doctest-docstrings
doctest-docstrings: $(OCT_COMPILED)
	@$(subst PKG,doctest,$(OCTAVE_INSTALL_MISSING:PKG=doctest))
	@echo " [OCTAVE] doctest"
	@$(OCTAVE) $(OCTAVE_REPRODUCIBLE_OPTIONS) $(OCTAVE_WORKSPACE_PATH) \
		--eval \
		"pkg load doctest; \
		 set (0, 'defaultfigurevisible', 'off'); \
		 targets = '@infsup @infsupdec $(shell find inst/ src/ -maxdepth 1 -regex ".*\\.\\(m\\|oct\\)" -printf "%f\\n" | cut -f1 -d.)'; \
		 targets = strsplit (targets, ' '); \
		 success = doctest (targets); \
		 exit (!success)"

.PHONY: doctest
doctest: doctest-docstrings doctest-manual

.PHONY: check
check: doctest test

##
## Part D: Miscellaneous utilities
##

## GNU LilyPond graphics
## This is an exotic dependency for an Octave package, so the generated SVG
## is under version control and only gets recreated when LilyPond is installed.
LILYPOND ?= $(shell which lilypond 2> /dev/null)
ifneq ($(LILYPOND),)
doc/image/%.svg: doc/image/%.ly
	@echo " [LILYPOND] $<"
	@# .ly -> .eps
	@$(LILYPOND) --ps --output "$(BUILD_DIR)/$<" --silent "$<"
	@# .eps -> .pdf (with size optimizations)
	@epstopdf "$(BUILD_DIR)/$<.eps"
	@# .pdf -> .ps (convert font glyphs to outline shapes)
	@gs -q -o "$(BUILD_DIR))/$<.ps" -dNOCACHE -sDEVICE=pswrite "$(BUILD_DIR)/$<.pdf"
	@# .ps -> .svg
	@inkscape --without-gui --export-ignore-filters --export-plain-svg="$@" "$(BUILD_DIR)/$<.ps"
endif

## Push the new release to Debian
## (inspired by https://xkcd.com/1597/ because I always forget the required commands)
.PHONY: debian
debian:
	cp "$(RELEASE_TARBALL_COMPRESSED)" "../Debian/octave-$(PACKAGE)_$(VERSION).orig.tar.gz"
	(cd ../Debian/octave-$(PACKAGE) && \
	 gbp import-orig ../octave-$(PACKAGE)_$(VERSION).orig.tar.gz --pristine-tar)
