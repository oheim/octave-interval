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
## @deftypefn {Interval Function} {@var{Y} =} acos (@var{X})
## @cindex IEEE1788 acos
## 
## Compute the inverse cosine in radians (arccosine) for each number in
## interval @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## acos (infsup (.5))
##   @result{} [1.0471975511965976, 1.0471975511965979]
## @end group
## @end example
## @seealso{cos}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = acos (x)

if (isempty (x) || x.inf > 1 || x.sup < -1)
    result = empty ();
    return
endif

if (x.inf <= -1)
    ## pi
    ac.sup = 0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55); 
else
    fesetround (inf);
    ac.sup = acos (x.inf);
    fesetround (0.5);
endif

if (x.sup >= 1)
    ac.inf = 0;
else
    fesetround (-inf);
    ac.inf = acos (x.sup);
    fesetround (0.5);
endif

result = infsup (ac.inf, ac.sup);

endfunction