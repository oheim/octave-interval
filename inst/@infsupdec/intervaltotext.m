## Copyright 2014 Oliver Heimlich
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Interval Output} {@var{S} =} intervaltotext (@var{X})
## @deftypefnx {Interval Output} {@var{S} =} intervaltotext (@var{X}, @var{EXACT})
## @cindex IEEE1788 intervalToText
## 
## Build an approximate representation of the interval @var{X} in decimal
## format.
##
## The interval boundaries are stored in binary floating point format and are
## converted to decimal format with possible precision loss. If output is not
## exact, the boundaries are rounded accordingly (e. g. the upper boundary is
## rounded towards infinite for output representation).
##
## Enough decimal digits are used to ensure separation of subsequent floting
## point numbers.
##
## Accuracy: For all intervals @var{X} is an accurate subset of
## @code{texttointerval (intervaltotext (@var{X}))}.  If parameter @var{EXACT}
## is used and is set to @code{True} the output is exact.
## @seealso{texttointerval, intervaltoexact}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-12

function s = intervaltotext (x, exact)

if (nargin < 2)
    exact = false ();
endif

if (isnai (x))
    s = "[NaI]";
else
    ## Using intervalpart we can call the superclass' method.
    ## In later GNU Octave versions it is also possible to call
    ## intervaltotext@infsup (x, exact);
    s = intervaltotext (intervalpart (x), exact);
    s = strcat (s, "_", x.dec);
endif

endfunction