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
## @deftypefn {Interval Numeric} {@var{Y} =} mig (@var{X})
## @cindex IEEE1788 mig
## 
## Get the mignitude of numbers in interval @var{X}, that is the minimum of
## absolute values for each element.
##
## If @var{X} is empty, @code{mig (@var{X})} is NaN.
##
## Accuracy: The result is exact.
##
## @example
## @group
## mig (infsup (-2, -1))
##   @result{} 1
## @end group
## @end example
## @seealso{mag, inf, sup}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = mig (x)

if (isempty (x))
    result = nan ();
    return
endif

if (sign (x.inf) == sign (x.sup))
    result = min (abs (x.inf), abs (x.sup));
else
    result = 0;
endif

endfunction