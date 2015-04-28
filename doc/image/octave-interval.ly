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

\score {
  % Between d' and d'' lies an octave interval.
  \new Voice = "" { { <d' d''>1 } }
  % Frequency of d' in just intonation is approx. 293,7 Hz,
  % wheras d'' has this doubled.
  \addlyrics { \lyricmode { "[293, 588]" } }
  \layout { }
}
