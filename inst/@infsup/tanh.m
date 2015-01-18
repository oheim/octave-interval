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
## @deftypefn {Function File} {} tanh (@var{X})
## 
## Compute the hyperbolic tangent.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## tanh (infsup (1))
##   @result{} [.7615941559557648, .761594155955765]
## @end group
## @end example
## @seealso{@@infsup/atanh, @@infsup/sinh, @@infsup/cosh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = tanh (x)

l = mpfr_function_d ('tanh', -inf, x.inf);
u = mpfr_function_d ('tanh', +inf, x.sup);

nonnegative = x.inf >= 0;
l (nonnegative) = max (0, l (nonnegative));
nonpositive = x.sup <= 0;
u (nonpositive) = min (0, u (nonpositive));

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction
