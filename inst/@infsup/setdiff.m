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
## @defmethod {@@infsup} setdiff (@var{A}, @var{B})
## 
## Build the relative complement of interval @var{B} in interval @var{A}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (1, 3);
## y = infsup (2, 4);
## setdiff (x, y)
##   @result{} ans = [1, 2]
## @end group
## @end example
## @seealso{@@infsup/intersect, @@infsup/union, @@infsup/setxor}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-03

function result = setdiff (a, b)

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

l = a.inf;
u = a.sup;

select = b.sup >= a.sup & b.inf > a.inf;
u (select) = min (u (select), b.inf (select));

select = b.inf <= a.inf & b.sup < a.sup;
l (select) = max (l (select), b.sup (select));

emptyresult = b.inf <= a.inf & b.sup >= a.sup;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!assert (isempty (setdiff (infsup (), infsup (1, 4))));
%!assert (setdiff (infsup (1, 3), infsup ()) == infsup (1, 3));
%!assert (isempty (setdiff (infsup (1, 3), infsup (-inf, inf))));
%!assert (isempty (setdiff (infsup (1, 3), infsup (1, 4))));
%!assert (setdiff (infsup (-inf, inf), infsup (1, 4)) == infsup (-inf, inf));
%!test "from the documentation string";
%! assert (setdiff (infsup (1, 3), infsup (2, 4)) == infsup (1, 2));
