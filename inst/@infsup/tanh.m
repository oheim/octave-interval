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
## @defmethod {@@infsup} tanh (@var{X})
## 
## Compute the hyperbolic tangent.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## tanh (infsup (1))
##   @result{} ans ⊂ [0.76159, 0.7616]
## @end group
## @end example
## @seealso{@@infsup/atanh, @@infsup/coth, @@infsup/sinh, @@infsup/cosh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = tanh (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

## tanh is monotonically increasing from (-inf, -1) to (inf, 1)
l = mpfr_function_d ('tanh', -inf, x.inf);
u = mpfr_function_d ('tanh', +inf, x.sup);

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (tanh (infsup (1)) == "[0x1.85EFAB514F394p-1, 0x1.85EFAB514F395p-1]");
