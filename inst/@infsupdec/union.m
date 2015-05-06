## Copyright 2014-2015 Oliver Heimlich
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
## @documentencoding UTF-8
## @deftypefn {Function File} {} {} union (@var{A}, @var{B})
## 
## Build the interval hull of the union of two intervals.
##
## Accuracy: The result is exact.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## The function is a set operation and the result carries the @code{trv}
## decoration at best.
##
## @example
## @group
## x = infsupdec (1, 3);
## y = infsupdec (2, 4);
## union (x, y)
##   @result{} ans = [1, 4]_trv
## @end group
## @end example
## @seealso{hull, @@infsupdec/intersect, @@infsupdec/setdiff, @@infsupdec/setxor}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = union (a, b)

if (nargin ~= 2)
    print_usage ();
    return
endif

if (not (isa (a, "infsupdec")))
    a = infsupdec (a);
endif
if (not (isa (b, "infsupdec")))
    b = infsupdec (b);
endif

if (isnai (a))
    result = a;
    return
endif
if (isnai (b))
    result = b;
    return
endif

## convexHull must not retain any useful decoration
result = infsupdec (union (intervalpart (a), intervalpart (b)), "trv");

endfunction

%!test "from the documentation string";
%! assert (isequal (union (infsupdec (1, 3), infsupdec (2, 4)), infsupdec (1, 4, "trv")));
