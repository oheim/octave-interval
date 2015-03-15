## Copyright 2015 Oliver Heimlich
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
## @deftypefn {Function File} {} cbrt (@var{X})
## 
## Compute the cube root (for all non-negative numbers).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## cbrt (infsup (-6, 27))
##   @result{} [0, 3]
## @end group
## @end example
## @seealso{@@infsup/realsqrt, @@infsup/nthroot}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function result = cbrt (x)

l = mpfr_function_d ('cbrt', -inf, max (0, x.inf));
u = mpfr_function_d ('cbrt', +inf, max (0, x.sup));

emptyresult = isempty (x) | x.sup < 0;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (cbrt (infsup (-6, 27)) == infsup (0, 3));
