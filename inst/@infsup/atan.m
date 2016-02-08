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
## @defmethod {@@infsup} atan (@var{X})
## 
## Compute the inverse tangent in radians.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## atan (infsup (1))
##   @result{} ans ⊂ [0.78539, 0.7854]
## @end group
## @end example
## @seealso{@@infsup/tan, @@infsup/atan2}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = atan (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

## atan is monotonically increasing
l = mpfr_function_d ('atan', -inf, x.inf);
u = mpfr_function_d ('atan', +inf, x.sup);

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (atan (infsup (1)) == "[0x1.921FB54442D18p-1, 0x1.921FB54442D19p-1]");
