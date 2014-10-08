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
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## tanh (infsup (1))
##   @result{} [.7615941559557647, .761594155955765]
## @end group
## @end example
## @seealso{atanh, sinh, cosh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = tanh (x)

if (isempty (x))
    result = empty ();
    return
endif

if (x.inf == 0)
    th.inf = 0;
else
    fesetround (-inf);
    th.inf = tanh (x.inf);
endif

if (x.sup == 0)
    th.sup = 0;
else
    fesetround (inf);
    th.sup = tanh (x.sup);
endif
fesetround (0.5);

result = infsup (th.inf, th.sup);

endfunction