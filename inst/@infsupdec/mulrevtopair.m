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
## @documentencoding utf-8
## @deftypefn {Function File} {[@var{U}, @var{V}] =} mulrevtopair (@var{X}, @var{Y})
## 
## Divide all numbers of interval @var{X} by all numbers of @var{Y}.  If the 
## set division of the intervals would be a union of two disjoint intervals,
## this function returns an enclosure of both intervals separately.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsupdec (1);
## y = infsupdec (-inf, inf);
## [u, v] = mulrevtopair (x, y)
##   @result{} [-Inf, 0]_trv
##   @result{} [0, Inf]_trv
## @end group
## @end example
## @seealso{@@infsupdec/mrdivide}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function [u, v] = mulrevtopair (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif

if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif

if (isnai (x))
    result = x;
    return
endif
if (isnai (y))
    result = y;
    return
endif

[u, v] = mulrevtopair (intervalpart (x), intervalpart (y));
u = infsupdec (u);
u.dec = mindec (u.dec, x.dec, y.dec);
v = infsupdec (v);
v.dec = mindec (v.dec, x.dec, y.dec);

divisionbyzero = ismember (0, y);
if (isscalar (y) && not (isscalar (x)))
    divisionbyzero = divisionbyzero * ones (size (x));
endif
u.dec (divisionbyzero) = "trv";
v.dec (divisionbyzero) = "trv";

endfunction