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
## @defmethod {@@infsup} atanh (@var{X})
## 
## Compute the inverse hyperbolic tangent.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## atanh (infsup (.5))
##   @result{} ans ⊂ [0.5493, 0.54931]
## @end group
## @end example
## @seealso{@@infsup/tanh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = atanh (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

x = intersect (x, infsup (-1, 1));

## atanh is monotonically increasing between (-1, -inf) and (1, inf)
l = mpfr_function_d ('atanh', -inf, x.inf);
u = mpfr_function_d ('atanh', +inf, x.sup);

emptyresult = isempty (x) | x.sup <= -1 | x.inf >= 1;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (atanh (infsup (.5)) == "[0x1.193EA7AAD030Ap-1, 0x1.193EA7AAD030Bp-1]");
