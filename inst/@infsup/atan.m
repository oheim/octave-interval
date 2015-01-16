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
## @deftypefn {Function File} {} atan (@var{X})
## 
## Compute the inverse tangent in radians.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## atan (infsup (1))
##   @result{} [.7853981633974482, .7853981633974484]
## @end group
## @end example
## @seealso{tan, atan2}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = atan (x)

l = mpfr_function_d ('atan', -inf, x.inf);
u = mpfr_function_d ('atan', +inf, x.sup);

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction