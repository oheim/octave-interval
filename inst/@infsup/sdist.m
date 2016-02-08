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
## @defmethod {@@infsup} sdist (@var{X}, @var{Y})
## 
## Compute the signed distance between two intervals as sets.
##
## The signed distance for closed real intervals is the minimum distance
## between each pair of numbers, where the result's sign indicates whether
## @var{x} precedes @var{y} (negative), @var{y} precedes @var{x} (positive), or
## @var{x} intersects @var{y} (zero).  That is, the signed distance equals zero
## if a number can be found in both intervals.  Otherwise the signed distance
## is the positive or negative size of the gap between both intervals on the
## real number lane.
##
## If any interval is empty, the result is NaN.  For interval matrices the
## result is computed entry-wise.
##
## Accuracy: The result is correctly-rounded (away from zero).
##
## @example
## @group
## sdist (infsup (0, 6), infsup (7, 20))
##   @result{} ans =  -1
## sdist (infsup (3, 5), infsup (0, 1))
##   @result{} ans =  2
## @end group
## @end example
## @seealso{@@infsup/idist, @@infsup/hdist}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-06-11

function result = sdist (x, y)

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
select = x.sup < y.inf;
if (any (any (select)))
    result (select) = ...
        mpfr_function_d ('minus', -inf, x.sup (select), y.inf (select));
endif
select = x.inf > y.sup;
if (any (any (select)))
    result (select) = max (result (select), ...
        mpfr_function_d ('minus', +inf, x.inf (select), y.sup (select)));
endif

result (isempty (x) | isempty (y)) = nan ();

endfunction

%!test "from the documentation string";
%! assert (sdist (infsup (0, 6), infsup (7, 20)), -1);
%! assert (sdist (infsup (3, 5), infsup (0, 1)), 2);
