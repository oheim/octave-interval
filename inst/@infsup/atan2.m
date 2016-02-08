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
## @defmethod {@@infsup} atan2 (@var{Y}, @var{X})
## 
## Compute the inverse tangent with two arguments.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## atan2 (infsup (1), infsup (-1))
##   @result{} ans ⊂ [2.3561, 2.3562]
## @end group
## @end example
## @seealso{@@infsup/tan}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = atan2 (y, x)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

## Resize, if scalar × matrix
if (isscalar (x.inf) ~= isscalar (y.inf))
    x.inf = ones (size (y.inf)) .* x.inf;
    x.sup = ones (size (y.inf)) .* x.sup;
    y.inf = ones (size (x.inf)) .* y.inf;
    y.sup = ones (size (x.inf)) .* y.sup;
endif

## Partitionize the function's domain
##          y
##         ^
##     p1  |  p2
##   ------0------>
##     p4  |  p3   x
##
x1 = x4 = intersect (x, infsup (-inf, 0));
y1 = y2 = intersect (y, infsup (0, inf));
x2 = x3 = intersect (x, infsup (0, inf));
y3 = y4 = intersect (y, infsup (-inf, 0));

## Intersect each partition with atan2's domain
p1 = not (isempty (x1) | isempty (y1)) & (x1.inf < 0 | y1.sup > 0);
p2 = not (isempty (x2) | isempty (y2)) & (x2.sup > 0 | y2.sup > 0);
p3 = not (isempty (x3) | isempty (y3)) & (x3.sup > 0 | y3.inf < 0);
p4 = not (isempty (x4) | isempty (y4)) & (x4.inf < 0 | y4.inf < 0);

## Prevent wrong limit values of atan2 (0, 0) in cases with y = 0.
x1.inf (p1 & y1.sup == 0) = x1.sup (p1 & y1.sup == 0) = -1;
x2.inf (p2 & y2.sup == 0) = x2.sup (p2 & y2.sup == 0) = 1;
x3.inf (p3 & y3.inf == 0) = x3.sup (p3 & y3.inf == 0) = 1;
p4 (y4.inf == 0) = false (); # don't consider y >= 0 in partition 4

## Prevent wrong limit values of atan2 (0, 0) in cases with x = 0.
y1.inf (p1 & x1.inf == 0) = y1.sup (p1 & x1.inf == 0) = 1;
y2.inf (p2 & x2.sup == 0) = y2.sup (p2 & x2.sup == 0) = 1;
y3.inf (p3 & x3.sup == 0) = y3.sup (p3 & x3.sup == 0) = -1;
y4.inf (p4 & x4.inf == 0) = y4.sup (p4 & x4.inf == 0) = -1;

## Fix interval boundaries for y = 0 and x < 0, because atan2 (±0, -eps) = ±pi
y1.inf (p1 & y1.inf == 0) = +0;
y4.sup (p4 & y4.sup == 0) = -0;

## Compute lower boundary (atan2 is increasing from p4 to p1)
l = inf (size (p1));
select = p4;
l (select) = mpfr_function_d ('atan2', -inf, y4.sup (select), x4.inf (select));
select = p3 & not (p4);
l (select) = mpfr_function_d ('atan2', -inf, y3.inf (select), x3.inf (select));
select = p2 & not (p3 | p4);
l (select) = mpfr_function_d ('atan2', -inf, y2.inf (select), x2.sup (select));
select = p1 & not (p2 | p3 | p4);
l (select) = mpfr_function_d ('atan2', -inf, y1.sup (select), x1.sup (select));

## Compute upper boundary (atan2 is decreasing from p1 to p4)
u = -inf (size (p1));
select = p1;
u (select) = mpfr_function_d ('atan2', +inf, y1.inf (select), x1.inf (select));
select = p2 & not (p1);
u (select) = mpfr_function_d ('atan2', +inf, y2.sup (select), x2.inf (select));
select = p3 & not (p1 | p2);
u (select) = mpfr_function_d ('atan2', +inf, y3.sup (select), x3.sup (select));
select = p4 & not (p1 | p2 | p3);
u (select) = mpfr_function_d ('atan2', +inf, y4.inf (select), x4.sup (select));

## Now, we have computed l and u for all cases where p1 | p2 | p3 | p4.  In all
## other cases, l and u will produce an empty interval.

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (atan2 (infsup (1), infsup (-1)) == "[0x1.2D97C7F3321D2p1, 0x1.2D97C7F3321D3p1]");
