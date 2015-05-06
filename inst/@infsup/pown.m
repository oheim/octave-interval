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
## @documentencoding UTF-8
## @deftypefn {Function File} {} pown (@var{X}, @var{P})
## 
## Compute the monomial @code{x^@var{P}} for all numbers in @var{X}.
##
## Monomials are defined for all real numbers and the special monomial
## @code{@var{P} == 0} evaluates to @code{1} everywhere.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## pown (infsup (5, 6), 2)
##   @result{} ans = [25, 36]
## @end group
## @end example
## @seealso{@@infsup/pow, @@infsup/pow2, @@infsup/pow10, @@infsup/exp}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = pown (x, p)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isnumeric (p)) || fix (p) ~= p)
    error ("interval:InvalidOperand", "pown: exponent is not an integer");
endif

if (p == 1) # x^1
    result = infsup (x.inf, x.sup);
    return
endif

if (p == 0) # x^0
    result = infsup (ones (size (x)));
    result.inf (isempty (x)) = inf;
    result.sup (isempty (x)) = -inf;
    return
endif

if (p == 2) # x^2
    result = sqr (x);
    return
endif

if (rem (p, 2) == 0) # p even
    x.mig = mig (x);
    x.mag = mag (x);
    x.inf = x.mig;
    x.inf (isnan (x.inf)) = inf;
    x.sup = x.mag;
    x.sup (isnan (x.sup)) = -inf;
    result = pow (x, p);
else # p odd
    result = union (pow (x, infsup (p)), ...
                    -pow (-x, infsup (p)));
endif

## Special case: x = [0]. The pow function used above would be undefined.
if (p >= 0)
    zero = x.inf == 0 & x.sup == 0;
    result.inf (zero) = -0;
    result.sup (zero) = +0;
endif

endfunction

%!test "from the documentation string";
%! assert (pown (infsup (5, 6), 2) == infsup (25, 36));
