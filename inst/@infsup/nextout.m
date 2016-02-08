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
## @defmethod {@@infsup} nextout (@var{X})
## 
## Increases the interval's boundaries in each direction to the next number.
##
## This is the equivalent function to IEEE 754's nextDown and nextUp.
##
## @example
## @group
## x = infsup (1);
## nextout (x) == infsup (1 - eps / 2, 1 + eps)
##   @result{} ans = 1
## @end group
## @end example
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = nextout (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

delta = pow2 (-1074);
l = mpfr_function_d ('minus', -inf, x.inf, delta);
u = mpfr_function_d ('plus',  +inf, x.sup, delta);

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! x = nextout (infsup (1));
%! assert (inf (x), 1 - eps / 2);
%! assert (sup (x), 1 + eps);
