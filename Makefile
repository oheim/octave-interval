SHELL   = /bin/sh

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

$(RELEASE_TARBALL_COMPRESSED): $(RELEASE_TARBALL) $(GENERATED_NEWS) $(GENERATED_COPYING)
	@tar --append --file "$<" --transform="s!^$(BUILD_DIR)/!$(PACKAGE)-$(VERSION)/!" "$(GENERATED_NEWS)" "$(GENERATED_COPYING)"
	@(cd "$(BUILD_DIR)" && gzip --best -f -k "../$<")

$(INSTALLED_PACKAGE): $(RELEASE_TARBALL_COMPRESSED)
	@echo "Installing package in GNU Octave ..."
	@$(OCTAVE) --silent --eval "pkg install $<"

$(GENERATED_HTML): $(INSTALLED_PACKAGE)
	@echo "Generating HTML documentation for the package. This may take a while ..."
	@$(OCTAVE) --silent --eval "pkg load generate_html; options = get_html_options ('octave-forge'); options.package_doc = 'manual.texinfo'; generate_package_html ('$(PACKAGE)', '$(HTML_DIR)', options)"

$(GENERATED_NEWS): doc/news.texinfo
	@echo "Compiling NEWS file ..."
	@makeinfo --plaintext --output="$@" "$<" 

$(GENERATED_COPYING): doc/copying.texinfo
	@echo "Compiling COPYING file ..."
	@makeinfo --plaintext --output="$@" "$<" 

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
	@$(OCTAVE) --silent --path "inst/" --path "src/" --path "$(DOCTEST_HOME)" --eval "doctest $(shell (ls inst; ls src | grep .oct) | cut -f2 -d@ | cut -f1 -d.)"
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
	@tar --append --file "$<" --transform="s!^$(TST_GENERATED_DIR)/!$(PACKAGE)-$(VERSION)/inst/!" $(TST_GENERATED_DIR)/*

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
