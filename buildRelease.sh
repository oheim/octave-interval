#!/bin/bash
# Helper script for the package release
# See documentation at http://octave.sourceforge.net/developers.html

PACKAGE=`grep "^Name: " DESCRIPTION | cut -f2 -d" "`
VERSION=`grep "^Version: " DESCRIPTION | cut -f2 -d" "`
TARGET=$PACKAGE-$VERSION.tar.gz
TARGET_DOC=$PACKAGE-html.tar.gz

echo "Creating package archive ..."
hg archive --exclude '.hg*' --exclude "$0" $TARGET
echo "Installing package ..."
octave --quiet --eval "pkg install $TARGET"
echo "Updating generate_html package ..."
octave --quiet --eval "pkg install -forge generate_html"
echo "Generating documentation, this may take some time ..."
octave --quiet --eval "pkg load generate_html; generate_package_html ('$PACKAGE', '$PACKAGE-html', 'octave-forge')"

# The generate_html script breaks the html file encodings, fix it
echo "Fixing html file encodings ..."
HTML_PAGES=$(find ./$PACKAGE-html/ -name '*.html')
for file in $HTML_PAGES
  do
    # Documentation strings are in UTF-8, not in ASCII
    sed -i 's/content="text\/html; charset=iso-8859-1"/content="text\/html; charset=utf-8"/g' $file
    # The __makeinfo__ function accidentally performs a conversion from ASCII to UTF-8
    iconv -f utf-8 -t iso-8859-1 -o $file.tmp $file
    mv -f $file.tmp $file
  done

echo "Creating documentation archive ..."
tar czf $TARGET_DOC $PACKAGE-html
rm -rf $PACKAGE-html
echo "Done."
md5sum $TARGET $TARGET_DOC
