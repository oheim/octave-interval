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
## @deftypemethod {@@infsupdec} {} setxor (@var{A}, @var{B})
## @deftypemethodx {@@infsupdec} {[@var{C}, @var{C1}, @var{C2}] =} setxor (@var{A}, @var{B})
## 
## Build the symmetric difference of intervals @var{A} and @var{B}.
##
## With three output arguments, return intervals @var{C1} and @var{C2} such
## that @var{C1} and @var{C2} are enclosures of disjoint sets whose union is
## enclosed by interval @var{C}.
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
## [z, z1, z2] = setxor (x, y)
##   @result{}
##     z = [1, 4]_trv
##     z1 = [1, 2]_trv
##     z2 = [3, 4]_trv
## @end group
## @end example
## @seealso{@@infsupdec/intersect, @@infsupdec/union, @@infsupdec/setdiff}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-03

function [c, c1, c2] = setxor (a, b)

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
    c = c1 = c2 = a;
    return
endif
if (isnai (b))
    c = c1 = c2 = b;
    return
endif

if (nargout > 1)
    [c, c1, c2] = setxor (intervalpart (a), intervalpart (b));
    c1 = infsupdec (c1, "trv");
    c2 = infsupdec (c2, "trv");
else
    c = setxor (intervalpart (a), intervalpart (b));
endif

c = infsupdec (c, "trv");

endfunction

%!test
%! [z, z1, z2] = setxor (infsupdec (), infsupdec ());
%! assert (isempty (z));
%! assert (isempty (z1));
%! assert (isempty (z2));
%!test
%! [z, z1, z2] = setxor (infsupdec (-inf, inf), infsupdec ());
%! assert (isentire (z));
%! assert (isentire (z1));
%! assert (isempty (z2));
%!test
%! [z, z1, z2] = setxor (infsupdec (-inf, inf), infsupdec (2));
%! assert (isentire (z));
%! assert (z1 == infsupdec (-inf, 2));
%! assert (z2 == infsupdec (2, inf));
%!test
%! [z, z1, z2] = setxor (infsupdec (2, 3), infsupdec (2));
%! assert (z == infsupdec (2, 3));
%! assert (z1 == infsupdec ());
%! assert (z2 == infsupdec (2, 3));
%!test
%! [z, z1, z2] = setxor (infsupdec (2, 3), infsupdec (2, 2.5));
%! assert (z == infsupdec (2.5, 3));
%! assert (z1 == infsupdec ());
%! assert (z2 == infsupdec (2.5, 3));
%!test "from the documentation string";
%! [z, z1, z2] = setxor (infsupdec (1, 3), infsupdec (2, 4));
%! assert (z == infsupdec (1, 4));
%! assert (z1 == infsupdec (1, 2));
%! assert (z2 == infsupdec (3, 4));
