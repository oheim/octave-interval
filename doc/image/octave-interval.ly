%% Copyright 2015 Oliver Heimlich
%%
%% Copying and distribution of this file, with or without modification,
%% are permitted in any medium without royalty provided the copyright
%% notice and this notice are preserved.  This file is offered as-is,
%% without any warranty.

\include "lilypond-book-preamble.ly"

\paper {
  indent = 0\mm
  line-width = 6\in
  % offset the left padding, also add 1mm as lilypond creates cropped
  % images with a little space on the right
  line-width = #(- line-width (* mm  3.000000) (* mm 1))
}

\layout {
}

{
  <c' c''>1
}

