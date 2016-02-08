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
## @defmethod {@@infsup} cosh (@var{X})
## 
## Compute the hyperbolic cosine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## cosh (infsup (1))
##   @result{} ans ⊂ [1.543, 1.5431]
## @end group
## @end example
## @seealso{@@infsup/acosh, @@infsup/sech, @@infsup/sinh, @@infsup/tanh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = cosh (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

## cosh is symmetric and has its global minimum located at (0, 0).
l = mpfr_function_d ('cosh', -inf, mig (x));
u = mpfr_function_d ('cosh', +inf, mag (x));

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (cosh (infsup (1)) == "[0x1.8B07551D9F55, 0x1.8B07551D9F551]");
