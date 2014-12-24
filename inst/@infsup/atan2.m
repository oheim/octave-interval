## Copyright 2014 Oliver Heimlich
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
## @deftypefn {Interval Function} {} atan2 (@var{Y}, @var{X})
## @cindex IEEE1788 atan2
## 
## Compute the inverse tangent with two arguments for each pair of numbers from
## intervals @var{Y} and @var{X}.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 5 ULPs of the exact enclosure.
##
## @example
## @group
## atan2 (infsup (1), infsup (-1))
##   @result{} [2.3561944901923435, 2.3561944901923462]
## @end group
## @end example
## @seealso{tan}
## @end deftypefn

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

l = u = zeros (size (x.inf));

## Partitionize the function's domain
q1 = (x.sup <= 0 & y.inf >= 0);
q2 = (x.sup <= 0 & y.sup <= 0 & y.inf < 0);
q3 = (x.sup <= 0 & y.inf < 0 & 0 < y.sup);
q4 = (x.inf >= 0 & x.sup > 0 & y.inf >= 0);
q5 = (x.inf >= 0 & x.sup > 0 & y.sup <= 0 & y.inf < 0);
q6 = (x.inf >= 0 & x.sup > 0 & y.inf < 0 & 0 < y.sup);
q7 = (x.inf < 0 & 0 < x.sup);
q71 = q7 & y.inf > 0;
q72 = q7 & y.sup < 0;

## The atan2 should be within 2.5 ULPs of the exact result.
## The atan2 with directed rounding is 2 ULPs within tight result.
fesetround (-inf);
l (q1) = atan2 (y.sup (q1), x.sup (q1));
l (q2) = atan2 (y.sup (q2), x.inf (q2));
l (q4) = atan2 (y.inf (q4), x.sup (q4));
l (q5) = atan2 (y.inf (q5), x.inf (q5));
l (q6) = atan2 (y.inf (q6), x.inf (q6));
l (q71) = atan2 (y.inf (q71), x.sup (q71));
l (q72) = atan2 (y.sup (q72), x.inf (q72));
fesetround (inf);
u (q1) = atan2 (y.inf (q1), x.inf (q1));
u (q2) = atan2 (y.inf (q2), x.sup (q2));
u (q4) = atan2 (y.sup (q4), x.inf (q4));
u (q5) = atan2 (y.sup (q5), x.sup (q5));
u (q6) = atan2 (y.sup (q6), x.inf (q6));
u (q71) = atan2 (y.inf (q71), x.inf (q71));
u (q72) = atan2 (y.sup (q72), x.sup (q72));
fesetround (0.5);

## Consider ULP accurracy
l = ulpadd (l, -2);
u = ulpadd (u, 2);

## Make function tightest for some parameters and compute remaining partitions
pi = infsup ("pi");
l (q1) = max (l (q1), inf (pi) / 2);
l (q1 & (y.sup == inf | x.sup == 0)) = inf (pi) / 2;
l (q1 & y.sup == 0) = inf (pi);
u (q1) = min (u (q1), sup (pi));
u (q1 & (x.inf == -inf | y.inf == 0)) = sup (pi);
u (q1 & x.inf == 0) = sup (pi) / 2;

l (q2) = max (l (q2), inf (-pi));
l (q2 & x.inf == -inf) = inf (-pi);
l (q2 & x.inf == 0) = inf (-pi) / 2;
u (q2) = min (u (q2), inf (-pi));
u (q2 & (y.inf == -inf | x.sup == 0)) = sup (-pi) / 2;

q31 = q3 & x.inf ~= 0;
l (q31) = inf (-pi);
u (q31) = sup (pi);

q32 = q3 & x.inf == 0;
l (q32) = inf (-pi) / 2;
u (q32) = sup (pi) / 2;

l (q4) = max (l (q4), 0);
l (q4 & y.inf == 0) = 0;
l (q4 & x.sup == 0) = inf (pi) / 2;
u (q4) = min (u (q4), sup (pi) / 2);
u (q4 & x.inf == 0) = sup (pi) / 2;
u (q4 & y.sup == 0) = 0;

l (q5) = max (l (q5), inf (-pi) / 2);
l (q5 & x.inf == 0) = inf (-pi) / 2;
u (q5) = min (u (q5), sup (-pi) / 2);
u (q5 & y.sup == 0) = 0;
u (q5 & x.sup == 0) = sup (-pi) / 2;

l (q6) = max (l (q6), inf (-pi) / 2);
l (q6 & x.inf == 0) = inf (-pi) / 2;
u (q6) = min (u (q6), sup (pi) / 2);
u (q6 & x.inf == 0) = sup (pi) / 2;

l (q71) = max (l (q71), 0);
u (q71) = min (u (q71), sup (pi));

l (q72) = max (l (q72), inf (-pi));
u (q72) = min (u (q72), 0);

q73 = q7 & y.inf < 0 & y.sup >= 0;
l (q73) = inf (-pi);
u (q73) = sup (pi);

q74 = q7 & y.inf == 0;
l (q74) = 0;
u (q74) = sup (pi);

emptyresult = isempty (x) | isempty (y) | ...
              (x.inf == 0 & x.sup == 0 & y.inf == 0 & y.sup == 0);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction