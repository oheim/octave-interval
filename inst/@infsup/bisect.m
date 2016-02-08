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
## @deftypemethod {@@infsup} {[@var{A}, @var{B}] =} bisect (@var{X})
##
## Bisect an interval into two intervals, which contain half the amount of
## binary64 numbers each.
##
## Instead of bisecting the values of numbers in the interval at
## @code{mid (@var{X})}, this function bisects a function that counts them.  In
## a bisect method this eliminates exactly half of the solutions and avoids
## slow convergence speeds in extreme cases.
##
## If all numbers in interval @var{X} are of equal sign, the pivot element used
## for bisection is @code{pow2 (mid (log2 (abs (@var{X}))))}.  If @var{X} is no
## empty interval, the intervals @var{A} and @var{B} are non-empty and satisfy
## @code{@var{A}.sup == @var{B}.inf}.
##
## @example
## @group
## [a, b] = bisect (infsup (2, 32))
##   @result{} 
##     a = [2, 8]
##     b = [8, 32]
## @end group
## @end example
## @seealso{@@infsup/mince, @@infsup/nextout}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-05-25

function [a, b] = bisect (x)

if (nargin > 1)
    print_usage ();
    return
endif

m = zeros (size (x.inf));
idx.type = '()';

positive = x.inf >= 0 & x.sup > 0;
if (any (any (positive)))
    idx.subs = {positive};
    bounded = intersect (infsup (pow2 (-1074), realmax), subsref (x, idx));
    m (positive) = min (realmax (), pow2 (mid (log2 (bounded))));
endif

negative = x.inf < 0 & x.sup <= 0;
if (any (any (negative)))
    idx.subs = {negative};
    bounded = intersect (infsup (-realmax, -pow2 (-1074)), subsref (x, idx));
    m (negative) = ...
        uminus (min (realmax (), pow2 (mid (log2 (uminus (bounded))))));
endif

both_signs = x.inf < 0 & x.sup > 0;
both_signs_p = both_signs & x.sup > -x.inf;
if (any (any (both_signs_p)))
    idx.subs = {both_signs_p};
    bounded_n = intersect (infsup (-realmax, -pow2 (-1074)), subsref (x, idx));
    bounded_p = intersect (infsup (pow2 (-1074), realmax), subsref (x, idx));
    m (both_signs_p) = min (realmax (), pow2 (
        mid (log2 (bounded_p)) ...
        - mid (log2 (uminus (bounded_n))) ...
        - 1074));
endif

both_signs_n = both_signs & x.sup < -x.inf;
if (any (any (both_signs_n)))
    idx.subs = {both_signs_n};
    bounded_n = intersect (infsup (-realmax, -pow2 (-1074)), subsref (x, idx));
    bounded_p = intersect (infsup (pow2 (-1074), realmax), subsref (x, idx));
    m (both_signs_n) = uminus (min (realmax (), pow2 (
        mid (log2 (uminus (bounded_n))) ...
        - mid (log2 (bounded_p)) ...
        - 1074)));
endif

m (isempty (x)) = -inf;
a = infsup (x.inf, min (m, x.sup));
m (isempty (x)) = inf;
b = infsup (max (m, x.inf), x.sup);

endfunction

%!test "from the documentation string";
%! [a, b] = bisect (infsup (2, 32));
%! assert (a == infsup (2, 8));
%! assert (b == infsup (8, 32));
%!test
%! [a, b] = bisect (infsup (-inf, inf));
%! assert (a == infsup (-inf, 0));
%! assert (b == infsup (0, inf));
%!test
%! [a, b] = bisect (infsup (0));
%! assert (a == 0);
%! assert (b == 0);
%!test
%! [a, b] = bisect (infsup ());
%! assert (isempty (a));
%! assert (isempty (b));
%!test
%! [a, b] = bisect (infsup (0, inf));
%! assert (a == infsup (0, pow2 (-25)));
%! assert (b == infsup (pow2 (-25), inf));
%!test
%! [a, b] = bisect (infsup (-inf, 0));
%! assert (a == infsup (-inf, -pow2 (-25)));
%! assert (b == infsup (-pow2 (-25), 0));
