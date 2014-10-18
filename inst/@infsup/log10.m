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
## @deftypefn {Interval Function} {@var{Y} =} log10 (@var{X})
## @cindex IEEE1788 log10
## 
## Compute the decimal (base-10) logarithm for all numbers in interval @var{X}.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 7 ULPs of the tightest enclosure.
##
## @example
## @group
## log10 (infsup (2))
##   @result{} [.30102999566398097, .30102999566398143]
## @end group
## @end example
## @seealso{pow10, log, log2}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = log10 (x)

if (isempty (x) || x.sup <= 0)
    result = infsup ();
    return
endif

if (x.inf <= 0)
    l.inf = -inf;
else
    fesetround (-inf);
    l.inf = log10 (x.inf);
    fesetround (0.5);
    if (fix (l.inf) ~= l.inf || l.inf < 0 || l.inf > 22 || ...
        realpow (10, l.inf) ~= x.inf)
        ## Only exact for 10^n with n in [0, 22]
        ## Otherwise within 1.5 ULP (3 ULP guaranteed)
        l.inf = ulpadd (l.inf, -3);
    endif
endif

fesetround (inf);
l.sup = log10 (x.sup);
fesetround (0.5);
if (fix (l.sup) ~= l.sup || l.sup < 0 || l.sup > 22 || ...
    realpow (10, l.sup) ~= x.sup)
    l.sup = ulpadd (l.sup, 3);
endif

result = infsup (l.inf, l.sup);

endfunction