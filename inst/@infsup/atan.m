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
## @deftypefn {Interval Function} {@var{Y} =} atan (@var{X})
## @cindex IEEE1788 atan
## 
## Compute the inverse tangent in radians for each number in interval @var{X}.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## atan (infsup (1))
##   @result{} [.7853981633974481, .7853981633974484]
## @end group
## @end example
## @seealso{tan, atan2}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = atan (x)

if (isempty (x))
    result = infsup ();
    return
endif

at.sup = min (ulpadd (atan (x.sup), 1), ...
              ## pi / 2
              at.sup = 0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56));
at.inf = max (ulpadd (atan (x.inf), -1), ...
              ## - pi / 2
              - (0x6487ED5 * pow2 (-26) + 0x442D190 * pow2 (-56)));
if (x.inf >= 0)
    at.inf = max (0, at.inf);
endif
if (x.sup <= 0)
    at.sup = min (0, at.sup);
endif

result = infsup (at.inf, at.sup);

endfunction