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
	@hg archive --exclude ".hg*" --exclude "Makefile" --exclude "*.sh" --exclude "src/*.itl" "$@"

$(RELEASE_TARBALL_COMPRESSED): $(RELEASE_TARBALL)
	@(cd "$(BUILD_DIR)" && gzip -f -k "../$<")

$(INSTALLED_PACKAGE): $(RELEASE_TARBALL_COMPRESSED)
	@echo "Installing package in GNU Octave ..."
	@$(OCTAVE) --silent --eval "pkg install $<"

$(GENERATED_HTML): $(INSTALLED_PACKAGE)
	@echo "Generating HTML documentation for the package. This may take a while ..."
	@$(OCTAVE) --silent --eval "pkg load generate_html; generate_package_html ('$(PACKAGE)', '$(HTML_DIR)', 'octave-forge')"

$(HTML_TARBALL_COMPRESSED): $(GENERATED_HTML)
	@tar --create --auto-compress --file "$@" "$(HTML_DIR)"

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

###################################################################
## The following rules are required for generation of test files ##
###################################################################

TST_SOURCES = $(wildcard src/*.itl)
TST_GENERATED_DIR = $(BUILD_DIR)/octave/native/P1788
TST_GENERATED = $(TST_SOURCES:src/%.itl=$(TST_GENERATED_DIR)/%.tst)
PWD = $(shell pwd)

.PHONY: tests
tests: $(TST_GENERATED)

$(TST_GENERATED_DIR)/%.tst: src/%.itl
	@echo "Compiling $< ..."
	@(cd "$(ITF1788_HOME)/src" && python3 main.py -f "$(shell basename $<)" -c "(octave, native, P1788)" -o "$(PWD)/$(BUILD_DIR)" -s "$(PWD)/src")
	@(echo "## DO NOT EDIT -- This file has been generated with the Interval Testing"; \
          echo "## Framework, which is available at: https://github.com/nehmeier/ITF1788"; \
          echo "## "; \
          echo "## The source code for this particular file is publicly available at:"; \
          echo -n "## https://sourceforge.net/p/octave/interval/ci/"; \
          echo -n $(shell hg log --limit 1 "$<" | head -1 | cut -f3 -d":"); \
          echo "/tree/$<"; \
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
