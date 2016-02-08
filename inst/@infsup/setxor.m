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
## @deftypemethod {@@infsup} {} setxor (@var{A}, @var{B})
## @deftypemethodx {@@infsup} {[@var{C}, @var{C1}, @var{C2}] =} setxor (@var{A}, @var{B})
## 
## Build the symmetric difference of intervals @var{A} and @var{B}.
##
## With three output arguments, return intervals @var{C1} and @var{C2} such
## that @var{C1} and @var{C2} are enclosures of disjoint sets whose union is
## enclosed by interval @var{C}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (1, 3);
## y = infsup (2, 4);
## [z, z1, z2] = setxor (x, y)
##   @result{}
##     z = [1, 4]
##     z1 = [1, 2]
##     z2 = [3, 4]
## @end group
## @end example
## @seealso{@@infsup/intersect, @@infsup/union, @@infsup/setdiff}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-03

function [c, c1, c2] = setxor (a, b)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (a, "infsup")))
    a = infsup (a);
endif
if (not (isa (b, "infsup")))
    b = infsup (b);
endif

## Resize, if scalar × matrix
if (isscalar (a.inf) ~= isscalar (b.inf))
    a.inf = ones (size (b.inf)) .* a.inf;
    a.sup = ones (size (b.inf)) .* a.sup;
    b.inf = ones (size (a.inf)) .* b.inf;
    b.sup = ones (size (a.inf)) .* b.sup;
endif

## Sort the four boundaries in ascending order b1 <= b2 <= b3 <= b4,
## if only one empty interval is present, then [b2, b3] = [Empty],
## with two empty intervals we also have [b1, b4] = [Empty].
b1 = min (a.inf, b.inf);
b2 = max (a.inf, b.inf);
b3 = min (a.sup, b.sup);
b4 = max (a.sup, b.sup);
[b2, b3] = deal (min (b2, b3), max (b2, b3));

l = b1;
u = b4;

select = a.inf == b.inf;
l (select) = b3 (select);

select = a.sup == b.sup;
u (select) = b2 (select);

select = a.inf == b.inf & a.sup == b.sup;
l (select) = inf;
u (select) = -inf;

c = infsup (l, u);

if (nargout > 1)
    select = isempty (a) | isempty (b);
    b1 (select) = a.inf (select);
    b2 (select) = a.sup (select);
    b3 (select) = b.inf (select);
    b4 (select) = b.sup (select);

    l1 = b1;
    u1 = b2;
    select = a.inf == b.inf;
    l1 (select) = inf;
    u1 (select) = -inf;
    c1 = infsup (l1, u1);
    
    l2 = b3;
    u2 = b4;
    select = a.sup == b.sup;
    l2 (select) = inf;
    u2 (select) = -inf;
    c2 = infsup (l2, u2);
endif

endfunction

%!test
%! [z, z1, z2] = setxor (infsup (), infsup ());
%! assert (isempty (z));
%! assert (isempty (z1));
%! assert (isempty (z2));
%!test
%! [z, z1, z2] = setxor (infsup (-inf, inf), infsup ());
%! assert (isentire (z));
%! assert (isentire (z1));
%! assert (isempty (z2));
%!test
%! [z, z1, z2] = setxor (infsup (-inf, inf), infsup (2));
%! assert (isentire (z));
%! assert (z1 == infsup (-inf, 2));
%! assert (z2 == infsup (2, inf));
%!test
%! [z, z1, z2] = setxor (infsup (2, 3), infsup (2));
%! assert (z == infsup (2, 3));
%! assert (z1 == infsup ());
%! assert (z2 == infsup (2, 3));
%!test
%! [z, z1, z2] = setxor (infsup (2, 3), infsup (2, 2.5));
%! assert (z == infsup (2.5, 3));
%! assert (z1 == infsup ());
%! assert (z2 == infsup (2.5, 3));
%!test "from the documentation string";
%! [z, z1, z2] = setxor (infsup (1, 3), infsup (2, 4));
%! assert (z == infsup (1, 4));
%! assert (z1 == infsup (1, 2));
%! assert (z2 == infsup (3, 4));
