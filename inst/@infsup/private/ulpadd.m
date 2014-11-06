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
## @deftypefn {Function File} {} ulpadd (@var{X}, @var{N})
## 
## Add @var{N} ULPs to the number @var{X}.  @var{N} may be negative.
##
## If the result would be no floating point number, the distance between
## @var{X} and @var{Y} may be larger than expected.
##
## @seealso{nextup, nextdown}
## @end deftypefn

## Author: Oliver Heimlich
## Created: 2014-10-18

function result = ulpadd (x, n)

if (not (isa (x, "double") && isscalar (n)))
    assert (false (), "Illegal call to ulpadd");
endif

if (abs (n) <= 1)
    ulp = pow2 (-1074);
else
    ulp = pow2 (max (-1074, floor (log2 (abs (x))) - 52));
endif

fesetround(sign (n) * inf);
result = x + n * ulp;
fesetround(0.5);

## If we subtract ULPs from inf, or add ULPs to -inf, the result would be NaN.
result (isnan (result)) = sign (x (isnan (result))) * realmax ();

endfunction