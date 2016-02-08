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
## @defmethod {@@infsup} fma (@var{X}, @var{Y}, @var{Z})
## 
## Fused multiply and add @code{@var{X} * @var{Y} + @var{Z}}.
##
## This function is semantically equivalent to evaluating multiplication and
## addition separately, but in addition guarantees a tight enclosure of the
## result.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## output_precision (16, 'local')
## fma (infsup (1+eps), infsup (7), infsup ("0.1"))
##   @result{} ans ⊂ [7.100000000000001, 7.100000000000003]
## infsup (1+eps) * infsup (7) + infsup ("0.1")
##   @result{} ans ⊂ [7.1, 7.100000000000003]
## @end group
## @end example
## @seealso{@@infsup/plus, @@infsup/times}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-03

function result = fma (x, y, z)

if (nargin ~= 3)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif
if (not (isa (z, "infsup")))
    z = infsup (z);
endif

## Resize, if scalar × matrix
if (isscalar (x.inf) ~= isscalar (y.inf))
    x.inf = ones (size (y.inf)) .* x.inf;
    x.sup = ones (size (y.inf)) .* x.sup;
    y.inf = ones (size (x.inf)) .* y.inf;
    y.sup = ones (size (x.inf)) .* y.sup;
endif
if (isscalar (y.inf) ~= isscalar (z.inf))
    y.inf = ones (size (z.inf)) .* y.inf;
    y.sup = ones (size (z.inf)) .* y.sup;
    z.inf = ones (size (y.inf)) .* z.inf;
    z.sup = ones (size (y.inf)) .* z.sup;
endif
if (isscalar (x.inf) ~= isscalar (z.inf))
    x.inf = ones (size (z.inf)) .* x.inf;
    x.sup = ones (size (z.inf)) .* x.sup;
    z.inf = ones (size (x.inf)) .* z.inf;
    z.sup = ones (size (x.inf)) .* z.sup;
endif

## [Empty] × anything = [Empty]
## [0] × anything = [0] × [0]
## [Entire] × anything but [0] = [Entire] × [Entire]
## This prevents the cases where 0 × inf would produce NaNs.
entireproduct = isentire (x) | isentire (y);
zeroproduct = (x.inf == 0 & x.sup == 0) | (y.inf == 0 & y.sup == 0);
emptyresult = isempty (x) | isempty (y) | isempty (z);
x.inf (entireproduct) = y.inf (entireproduct) = -inf;
x.sup (entireproduct) = y.sup (entireproduct) = inf;
x.inf (zeroproduct) = x.sup (zeroproduct) = ...
    y.inf (zeroproduct) = y.sup (zeroproduct) = 0;

## It is hard to determine, which boundaries of x and y take part in the
## multiplication of fma.  Therefore, we simply compute the fma for each triple
## of boundaries where the min/max could be located.
##
## How to construct complicated cases: a = rand, b = rand, c = rand,
## d = a * b / c (with round towards -infinity for multiplication and towards
## +infinity for division).  Then, it is not possible to decide in 50% of all
## cases whether a * b would be greater or less than c * d by computing the
## products in double-precision.

l = min (min (min (...
         mpfr_function_d ('fma', -inf, x.inf, y.inf, z.inf), ...
         mpfr_function_d ('fma', -inf, x.inf, y.sup, z.inf)), ...
         mpfr_function_d ('fma', -inf, x.sup, y.inf, z.inf)), ...
         mpfr_function_d ('fma', -inf, x.sup, y.sup, z.inf));
u = max (max (max (...
         mpfr_function_d ('fma', +inf, x.inf, y.inf, z.sup), ...
         mpfr_function_d ('fma', +inf, x.inf, y.sup, z.sup)), ...
         mpfr_function_d ('fma', +inf, x.sup, y.inf, z.sup)), ...
         mpfr_function_d ('fma', +inf, x.sup, y.sup, z.sup));

l (emptyresult) = +inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (fma (infsup (1+eps), infsup (7), infsup ("0.1")) == "[0x1.C666666666668p2, 0x1.C666666666669p2]");
