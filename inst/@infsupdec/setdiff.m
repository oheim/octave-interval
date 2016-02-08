## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsupdec} setdiff (@var{A}, @var{B})
## 
## Build the relative complement of interval @var{B} in interval @var{A}.
##
## Accuracy: The result is a tight enclosure.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## The function is a set operation and the result carries the @code{trv}
## decoration at best.
##
## @example
## @group
## x = infsupdec (1, 3);
## y = infsupdec (2, 4);
## setdiff (x, y)
##   @result{} ans = [1, 2]_trv
## @end group
## @end example
## @seealso{@@infsupdec/intersect, @@infsupdec/union, @@infsupdec/setxor}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-03

function result = setdiff (a, b)

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

result = infsupdec (setdiff (intervalpart (a), intervalpart (b)), "trv");

endfunction

%!assert (isempty (setdiff (infsupdec (), infsupdec (1, 4))));
%!assert (setdiff (infsupdec (1, 3), infsupdec ()) == infsupdec (1, 3));
%!assert (isempty (setdiff (infsupdec (1, 3), infsupdec (-inf, inf))));
%!assert (isempty (setdiff (infsupdec (1, 3), infsupdec (1, 4))));
%!assert (setdiff (infsupdec (-inf, inf), infsupdec (1, 4)) == infsupdec (-inf, inf));
%!test "from the documentation string";
%! assert (setdiff (infsupdec (1, 3), infsupdec (2, 4)) == infsupdec (1, 2));
