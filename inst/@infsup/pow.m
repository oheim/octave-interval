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
## @defmethod {@@infsup} pow (@var{X}, @var{Y})
## 
## Compute the simple power function on intervals defined by 
## @code{exp (@var{Y} * log (@var{X}))}.
##
## The function is only defined where @var{X} is positive or where @var{X} is
## zero and @var{Y} is positive.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## pow (infsup (5, 6), infsup (2, 3))
##   @result{} ans = [25, 216]
## @end group
## @end example
## @seealso{@@infsup/pown, @@infsup/pow2, @@infsup/pow10, @@infsup/exp, @@infsup/power}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = pow (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

## Resize, if scalar × matrix
if (isscalar (x.inf) ~= isscalar (y.inf))
    x.inf = ones (size (y.inf)) .* x.inf;
    x.sup = ones (size (y.inf)) .* x.sup;
    y.inf = ones (size (x.inf)) .* y.inf;
    y.sup = ones (size (x.inf)) .* y.sup;
endif

## Intersect with domain
x = intersect (x, infsup (0, inf));
y.inf (x.sup == 0) = max (0, y.inf (x.sup == 0));
y.sup (y.inf > y.sup) = -inf;
y.inf (y.inf > y.sup) = inf;

## Simple cases with no limit values, see Table 3.3 in
## Heimlich, Oliver. 2011. “The General Interval Power Function.”
## Diplomarbeit, Institute for Computer Science, University of Würzburg.
## http://exp.ln0.de/heimlich-power-2011.htm.
##
## The min/max is located at the boundaries of the input intervals.  Like with
## the times function we do not start a case by case analysis but simply
## compute all four combinations for each result boundary.
##
## We have to compensate for boundary x.inf = -0 with the abs function.
## Otherwise the limit values of the MPFR pow function would be wrong.

l = min (min (min (...
         mpfr_function_d ('pow', -inf, abs (x.inf), y.inf), ...
         mpfr_function_d ('pow', -inf, abs (x.inf), y.sup)), ...
         mpfr_function_d ('pow', -inf, x.sup, y.inf)), ...
         mpfr_function_d ('pow', -inf, x.sup, y.sup));
u = max (max (max (...
         mpfr_function_d ('pow', +inf, abs (x.inf), y.inf), ...
         mpfr_function_d ('pow', +inf, abs (x.inf), y.sup)), ...
         mpfr_function_d ('pow', +inf, x.sup, y.inf)), ...
         mpfr_function_d ('pow', +inf, x.sup, y.sup));

emptyresult = isempty (x) | isempty (y) | (x.sup == 0 & y.sup == 0);
l (emptyresult) = inf;
u (emptyresult) = -inf;

## Fix 0 ^ positive = 0
u (x.sup == 0 && u == 1) = 0;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (pow (infsup (5, 6), infsup (2, 3)) == infsup (25, 216));
