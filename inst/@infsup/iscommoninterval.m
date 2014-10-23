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
## @deftypefn {Interval Comparison} {@var{Y} =} iscommoninterval (@var{X})
## @cindex IEEE1788 isCommonInterval
## 
## Check if the interval is a common interval, that is a nonemty, closed
## bounded real interval.
##
## Common intervals are used in class Moore interval arithmetic and are
## flavor-independent in IEEE1788 interval arithmetic.
##
## @seealso{eq, isentire, isempty, issingleton}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-23

function result = iscommoninterval (x)

result = isfinite (x.inf) && isfinite (x.sup);
return