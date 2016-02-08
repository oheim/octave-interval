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
## @defmethod {@@infsup} asin (@var{X})
## 
## Compute the inverse sine in radians (arcsine).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## asin (infsup (.5))
##   @result{} ans ⊂ [0.52359, 0.5236]
## @end group
## @end example
## @seealso{@@infsup/sin}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = asin (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

x = intersect (x, infsup (-1, 1));

## asin is monotonically increasing from (-1, -pi/2) to (1, pi/2)
l = mpfr_function_d ('asin', -inf, x.inf);
u = mpfr_function_d ('asin', +inf, x.sup);

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "Empty interval";
%! assert (asin (infsup ()) == infsup ());
%!test "from the documentation string";
%! assert (asin (infsup (.5)) == "[0x1.0C152382D7365p-1, 0x1.0C152382D7366p-1]");
