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
## @deftypefn {Interval Function} {@var{Y} =} tanh (@var{X})
## @cindex IEEE1788 tanh
## 
## Compute the hyperbolic tangent for each number in interval @var{X}.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 3.5 ULPs of the exact enclosure.
##
## @example
## @group
## tanh (infsup (1))
##   @result{} [.7615941559557644, .7615941559557653]
## @end group
## @end example
## @seealso{atanh, sinh, cosh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = tanh (x)

if (isempty (x))
    result = infsup ();
    return
endif

## Using directed rounding, we can decrease the worst case error by 0.5 ULP
fesetround (-inf);
th.inf = tanh (x.inf);
fesetround (inf);
th.sup = tanh (x.sup);
fesetround (0.5);
th.inf = ulpadd (th.inf, -3);
th.sup = ulpadd (th.sup, 3);

if (x.inf >= 0)
    th.inf = max (0, th.inf);
endif
if (x.sup <= 0)
    th.sup = min (0, th.sup);
endif

result = infsup (th.inf, th.sup);

endfunction