## Copyright 2014-2016 Oliver Heimlich
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
## @deftypemethod {@@infsup} {@var{X} =} absrev (@var{C}, @var{X})
## @deftypemethodx {@@infsup} {@var{X} =} absrev (@var{C})
## 
## Compute the reverse absolute value function.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{abs (x) ∈ @var{C}}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## absrev (infsup (-2, 1))
##   @result{} ans = [-1, +1]
## @end group
## @end example
## @seealso{@@infsup/abs}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = absrev (c, x)

if (nargin < 1 || nargin > 2)
    print_usage ();
    return
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (nargin < 2)
    x = infsup (-inf, inf);
elseif (not (isa (x, "infsup")))
    x = infsup (x);
endif

## Compute the pre-image of abs for positive and negative x separately.
p = intersect (c, infsup (0, inf));
n = -p;

result = union (intersect (p, x), intersect (n, x));

endfunction

%!test "Empty interval";
%! assert (absrev (infsup ()) == infsup ());
%! assert (absrev (infsup (0, 1), infsup ()) == infsup ());
%! assert (absrev (infsup (0, 1), infsup (7, 9)) == infsup ());
%! assert (absrev (infsup (), infsup (0, 1)) == infsup ());
%! assert (absrev (infsup (-2, -1)) == infsup ());
%!test "Singleton intervals";
%! assert (absrev (infsup (1)) == infsup (-1, 1));
%! assert (absrev (infsup (0)) == infsup (0));
%! assert (absrev (infsup (-1)) == infsup ());
%! assert (absrev (infsup (realmax)) == infsup (-realmax, realmax));
%! assert (absrev (infsup (realmin)) == infsup (-realmin, realmin));
%! assert (absrev (infsup (-realmin)) == infsup ());
%! assert (absrev (infsup (-realmax)) == infsup ());
%!test "Bound intervals";
%! assert (absrev (infsup (1, 2)) == infsup (-2, 2));
%! assert (absrev (infsup (1, 2), infsup (0, 2)) == infsup (1, 2));
%! assert (absrev (infsup (0, 1), infsup (-0.5, 2)) == infsup (-0.5, 1));
%! assert (absrev (infsup (-1, 1)) == infsup (-1, 1));
%! assert (absrev (infsup (-1, 0)) == infsup (0));
%!test "Unbound intervals";
%! assert (absrev (infsup (0, inf)) == infsup (-inf, inf));
%! assert (absrev (infsup (-inf, inf)) == infsup (-inf, inf));
%! assert (absrev (infsup (-inf, 0)) == infsup (0));
%! assert (absrev (infsup (1, inf), infsup (-inf, 0)) == infsup (-inf, -1));
%! assert (absrev (infsup (-1, inf)) == infsup (-inf, inf));
%! assert (absrev (infsup (-inf, -1)) == infsup ());
%! assert (absrev (infsup (-inf, 1)) == infsup (-1, 1));
%!test "from the documentation string";
%! assert (absrev (infsup (-2, 1)) == infsup (-1, 1));
