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
## @deftypefn {Function File} {} atanh (@var{X})
## 
## Compute the inverse hyperbolic tangent.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## atanh (infsup (.5))
##   @result{} [.5493061443340547, .5493061443340549]
## @end group
## @end example
## @seealso{tanh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = atanh (x)

l = mpfr_function_d ('atanh', -inf, x.inf);
u = mpfr_function_d ('atanh', +inf, x.sup);

pi.sup = 0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55);

l (x.inf <= -1) = -pi.sup;
u (x.sup >= +1) = +pi.sup;

emptyresult = isempty (x) | x.sup <= -1 | x.inf >= 1;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction