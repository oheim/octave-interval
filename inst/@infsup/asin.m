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
## @deftypefn {Interval Function} {@var{Y} =} asin (@var{X})
## @cindex IEEE1788 asin
## 
## Compute the inverse sine in radians (arcsine) for each number in
## interval @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## asin (infsup (.5))
##   @result{} [.5235987755982988, .523598775598299]
## @end group
## @end example
## @seealso{sin}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = asin (x)

if (isempty (x) || x.inf > 1 || x.sup < -1)
    result = infsup ();
    return
endif

if (x.inf <= -1)
    ## - pi / 2
    as.inf = - (0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56)); 
else
    fesetround (-inf);
    as.inf = asin (x.inf);
    fesetround (0.5);
endif

if (x.sup >= 1)
    ## + pi / 2
    as.sup = 0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56);
else
    fesetround (inf);
    as.sup = asin (x.sup);
    fesetround (0.5);
endif

result = infsup (as.inf, as.sup);

endfunction