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
## @deftypefn {Interval Function} {} sin (@var{X})
## @cindex IEEE1788 sin
## 
## Compute the sine for each number in interval @var{X} in radians.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## sin (infsup (1))
##   @result{} [.8414709848078963, .8414709848078967]
## @end group
## @end example
## @seealso{asin, sinh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-05

function result = sin (x)

l = u = sinl = sinu = cossignl = cossignu = zeros (size (x));

## Check, if wid (x) is certainly greater than 2*pi. This can save the
## computation if some sine values.
fesetround (-inf);
width = x.sup - x.inf;
fesetround (0.5);
twopi.sup = 0x6487ED5 * pow2 (-24) + 0x442D190 * pow2 (-54);
certainlyfullperiod = width >= twopi.sup;
l (certainlyfullperiod) = -1;
u (certainlyfullperiod) = 1;

possiblynotfullperiod = not (certainlyfullperiod);
sinl (possiblynotfullperiod) = sin (x.inf (possiblynotfullperiod));
sinu (possiblynotfullperiod) = sin (x.sup (possiblynotfullperiod));

l (possiblynotfullperiod) = max (-1, ulpadd (min (...
        sinl (possiblynotfullperiod), sinu (possiblynotfullperiod)), -1));
u (possiblynotfullperiod) = min (1, ulpadd (max (...
        sinl (possiblynotfullperiod), sinu (possiblynotfullperiod)), 1));

## We use sign (cos) to know the gradient at the boundaries.
cossignl (possiblynotfullperiod) = sign (cos (x.inf (possiblynotfullperiod)));
cossignu (possiblynotfullperiod) = sign (cos (x.sup (possiblynotfullperiod)));

## In case of sign (cos) == 0, we conservatively use sign (cos) of nextout.
cossignl (cossignl == 0) = sign (sinl (cossignl == 0));
cossignu (cossignu == 0) = (-1) * sign (sinu (cossignu == 0));

containsinf = possiblynotfullperiod & ((cossignl == -1 & cossignu == 1) | ...
                                       (cossignl == cossignu & width > 4));
l (containsinf) = -1;

containssup = possiblynotfullperiod & ((cossignl == 1 & cossignu == -1) | ...
                                       (cossignl == cossignu & width > 4));
u (containssup) = 1;

## sin (0) == 0
l (x.inf == 0 & l == -pow2 (-1074)) = 0;
u (x.sup == 0 & u == pow2 (-1074)) = 0;

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction