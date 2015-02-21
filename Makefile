SHELL   = /bin/sh

PACKAGE = $(shell grep "^Name: " DESCRIPTION | cut -f2 -d" ")
VERSION = $(shell grep "^Version: " DESCRIPTION | cut -f2 -d" ")

.PHONY = dist all html info run install clean md5

dist: $(PACKAGE)-$(VERSION).tar.gz

all: dist html md5

html: $(PACKAGE)-html.tar.gz

install: ~/octave/$(PACKAGE)-$(VERSION)/packinfo/DESCRIPTION

clean:
	rm -rf $(PACKAGE)-html
	rm -f $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-html.tar.gz 

md5: $(PACKAGE)-$(VERSION).tar.gz $(PACKAGE)-html.tar.gz
	@md5sum $^

$(PACKAGE)-$(VERSION).tar.gz: .hg/dirstate
	hg archive --exclude ".hg*" --exclude "*.sh" --exclude "Makefile" $@

~/octave/$(PACKAGE)-$(VERSION)/packinfo/DESCRIPTION: $(PACKAGE)-$(VERSION).tar.gz
	octave --quiet --eval "pkg install $<"

$(PACKAGE)-html/$(PACKAGE)/index.html: ~/octave/$(PACKAGE)-$(VERSION)/packinfo/DESCRIPTION
	octave --quiet --eval "pkg load generate_html; generate_package_html ('$(PACKAGE)', '$(PACKAGE)-html', 'octave-forge')"

$(PACKAGE)-html.tar.gz: $(PACKAGE)-html/$(PACKAGE)/index.html
	tar czf $@ $(PACKAGE)-html

info:
	bash syncDocStrings.sh

run:
	# Run GNU Octave with the development version of the package
	(cd src; make install) && (cd inst; octave --silent)
