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
## @deftypefn {Interval Function} {} tan (@var{X})
## @cindex IEEE1788 tan
## 
## Compute the tangent for each number in interval @var{X} in radians.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## tan (infsup (1))
##   @result{} [1.557407724654902, 1.5574077246549026]
## @end group
## @end example
## @seealso{atan, tanh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = tan (x)

l = u = tanl = tanu = zeros (size (x));

## Check, if wid (x) is certainly greater than pi. This may save computation of
## some tangent values.
fesetround (-inf);
width = x.sup - x.inf;
fesetround (0.5);
pi.sup = 0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55);
certainlyfullperiod = width >= pi.sup;
l (certainlyfullperiod) = -inf;
u (certainlyfullperiod) = inf;

possiblynotfullperiod = not (certainlyfullperiod);
tanl (possiblynotfullperiod) = tan (x.inf);
tanu (possiblynotfullperiod) = tan (x.sup);

singularity = certainlyfullperiod | ...
              tanl > tanu | (...
                  width > 2 & (...
                      sign (tanl) == sign (tanu) | ...
                      max (abs (tanl), abs (tanu)) < 1));

nosingularity = not (singularity);
l (singularity) = -inf;
u (singularity) = inf;
l (nosingularity) = ulpadd (tanl (nosingularity), -1);
u (nosingularity) = ulpadd (tanu (nosingularity), 1);

## tan (0) == 0
l (nosingularity & x.inf == 0) = 0;
u (nosingularity & x.sup == 0) = 0;

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction