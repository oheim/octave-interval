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
## @deftypefn {Interval Function} {@var{Y} =} sinh (@var{X})
## @cindex IEEE1788 sinh
## 
## Compute the hyperbolic sine for each number in interval @var{X}.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 4 ULPs of the exact enclosure.
##
## @example
## @group
## sinh (infsup (1))
##   @result{} [1.1752011936438004, 1.1752011936438023]
## @end group
## @end example
## @seealso{asinh, cosh, tanh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = sinh (x)

if (isempty (x))
    result = infsup ();
    return
endif

sh.inf = ulpadd (sinh (x.inf), -4);
sh.sup = ulpadd (sinh (x.sup), 4);

if (x.inf >= 0)
    sh.inf = max (sh.inf, 0);
endif
if (x.sup <= 0)
    sh.sup = min (sh.sup, 0);
endif

result = infsup (sh.inf, sh.sup);

endfunction