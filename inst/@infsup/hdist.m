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
## @defmethod {@@infsup} hdist (@var{X}, @var{Y})
## 
## Compute the Hausdorff distance between two intervals as sets.
##
## The Hausdorff distance for closed real intervals is the maximum distance
## between both pairs of interval boundaries.
##
## If any interval is empty, the result is NaN.  For interval matrices the
## result is computed entry-wise.
##
## Accuracy: The result is correctly-rounded (towards infinity).
##
## @example
## @group
## hdist (infsup (1, 6), infsup (2, 8))
##   @result{} ans =  2
## @end group
## @end example
## @seealso{@@infsup/sdist, @@infsup/idist}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-06-11

function result = hdist (x, y)

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

result = zeros (size (x.inf));
select = x.inf < y.inf;
if (any (any (select)))
    result (select) = ...
        mpfr_function_d ('minus', +inf, y.inf (select), x.inf (select));
endif
select = x.inf > y.inf;
if (any (any (select)))
    result (select) = max (result (select), ...
        mpfr_function_d ('minus', +inf, x.inf (select), y.inf (select)));
endif
select = x.sup < y.sup;
if (any (any (select)))
    result (select) = max (result (select), ...
        mpfr_function_d ('minus', +inf, y.sup (select), x.sup (select)));
endif
select = x.sup > y.sup;
if (any (any (select)))
    result (select) = max (result (select), ...
        mpfr_function_d ('minus', +inf, x.sup (select), y.sup (select)));
endif

result (isempty (x) | isempty (y)) = nan ();

endfunction

%!test "from the documentation string";
%! assert (hdist (infsup (1, 6), infsup (2, 8)), 2);
