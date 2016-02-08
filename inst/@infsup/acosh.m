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
## @defmethod {@@infsup} acosh (@var{X})
## 
## Compute the inverse hyperbolic cosine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## acosh (infsup (2))
##   @result{} ans ⊂ [1.3169, 1.317]
## @end group
## @end example
## @seealso{@@infsup/cosh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = acosh (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

x = intersect (x, infsup (1, inf));

## acosh is monotonically increasing from (1, 0) to (inf, inf)
l = mpfr_function_d ('acosh', -inf, x.inf);
u = mpfr_function_d ('acosh', +inf, x.sup);

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "Empty interval";
%! assert (acosh (infsup ()) == infsup ());
%!test "Singleton intervals";
%! assert (acosh (infsup (0)) == infsup ());
%! assert (acosh (infsup (1)) == infsup (0));
%! x = infsup (1 : 3 : 100);
%! assert (min (subset (acosh (x), log (x + sqrt (x + 1) .* sqrt (x - 1)))));
%!test "Bounded intervals";
%! assert (acosh (infsup (0, 1)) == infsup (0));
%!test "Unbounded intervals";
%! assert (acosh (infsup (-inf, 0)) == infsup ());
%! assert (acosh (infsup (-inf, 1)) == infsup (0));
%! assert (acosh (infsup (0, inf)) == infsup (0, inf));
%! assert (acosh (infsup (1, inf)) == infsup (0, inf));
%! assert (subset (acosh (infsup (2, inf)), infsup (1, inf)));
%!test "from the documentation string";
%! assert (acosh (infsup (2)) == "[0x1.5124271980434, 0x1.5124271980435]");
