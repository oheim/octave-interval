## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsup} sech (@var{X})
## 
## Compute the hyperbolic secant, that is the reciprocal hyperbolic cosine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sech (infsup (1))
##   @result{} ans ⊂ [0.64805, 0.64806]
## @end group
## @end example
## @seealso{@@infsup/cosh, @@infsup/csch, @@infsup/coth}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function result = sech (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

l = mpfr_function_d ('sech', -inf, mag (x));
u = mpfr_function_d ('sech', +inf, mig (x));

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (sech (infsup (1)) == "[0x1.4BCDC50ED6BE7p-1, 0x1.4BCDC50ED6BE8p-1]");
