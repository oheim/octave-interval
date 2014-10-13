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
## @deftypefn {Interval Function} {@var{Y} =} asinh (@var{X})
## @cindex IEEE1788 asinh
## 
## Compute the inverse hyperbolic sine for each number in interval @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## asinh (infsup (1))
##   @result{} [.8813735870195429, .8813735870195431]
## @end group
## @end example
## @seealso{sinh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = asinh (x)

if (isempty (x))
    result = infsup ();
    return
endif

if (x.inf == 0)
    ash.inf = 0;
else
    fesetround (-inf);
    ash.inf = asinh (x.inf);
endif

if (x.sup == 0)
    ash.sup = 0;
else
    fesetround (inf);
    ash.sup = asinh (x.sup);
endif
fesetround (0.5);

result = infsup (ash.inf, ash.sup);

endfunction