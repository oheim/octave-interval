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

## -- IEEE 1788 constructor:  [X, ISEXACT] = texttointerval (S)
##
## Create an interval from an interval literal.
##
## For all intervals X is an accurate subset of
## texttointerval (intervaltotext (X)).  A second, logical output ISEXACT
## indicates if texttointerval (S) strictly equals the mathematical interval
## denoted by S.
##
## Supported literals: named constants and inf-sup form in decimal format.
##
## See also:
##  exacttointerval, intervaltotext
##
## Example:
##  w = texttointerval ("[empty]"); # empty set
##  x = texttointerval ("[2, 3]"); # exact interval from 2 to 3 (inclusive)
##  y = texttointerval ("[entire]"); # entire set of reals
##  z = texttointerval ("[2.1e-1]"); # thight enclosure of the decimal 0.21

## Author: Oliver Heimlich
## Keywords: interval constructor
## Created: 2014-09-30

function [interval, isexact] = texttointerval (s)

s = strtrim (s);

if (isempty (s) || s(1) ~= "[" || s(end) ~= "]")
    error ("interval string does not begin/end with square brackets")
endif

## Strip square brackets and whitespace
s = strtrim (s(2:end-1));

switch lower (s)
    case "entire"
        interval = entire ();
        isexact = true ();
    case "empty"
        interval = empty ();
        isexact = true ();
    otherwise
        s = strsplit (s, ",");
        if (isempty (s) || length (s) > 2)
            error ("interval string is not in inf-sup form")
        endif
        l = strtrim (s{1});
        if (length (s) == 1)
            u = l;
        else
            u = strtrim (s{2});
        endif
        ## All the logic in the infsup constructor can be used, except ...
        [interval, isexact] = infsup (l, u);
        ## ... this constructor must not allow construction of an empty
        ## interval.
        if (isempty (interval))
            error ("empty interval not allowed")
        endif
endswitch

endfunction
