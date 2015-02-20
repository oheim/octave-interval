## Copyright 2014-2015 Oliver Heimlich
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
## @deftypefn {Function File} {} sqrt (@var{X})
## 
## Compute the square root (for all non-negative numbers).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sqrt (infsup (-6, 4))
##   @result{} [0, 2]
## @end group
## @end example
## @seealso{@@infsup/sqr, @@infsup/pow}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-01

function result = sqrt (x)

l = mpfr_function_d ('sqrt', -inf, max (0, x.inf));
u = mpfr_function_d ('sqrt', +inf, max (0, x.sup));

emptyresult = isempty (x) | x.sup < 0;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (sqrt (infsup (-6, 4)) == infsup (0, 2));
