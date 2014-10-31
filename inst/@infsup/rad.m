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
## @deftypefn {Interval Numeric} {} rad (@var{X})
## @cindex IEEE1788 rad
## 
## Get the radius of interval @var{X}.
##
## If @var{X} is empty, @code{rad (@var{X})} is NaN.
## If @var{X} is unbounded in one or both directions, @code{rad (@var{X})} is 
## positive infinity.
##
## Accuracy: The result will make a tight enclosure of the interval together
## with @code{mid (@var{X})}.
##
## @example
## @group
## rad (infsup (2.5, 3.5))
##   @result{} 0.5
## @end group
## @end example
## @seealso{inf, sup, mid, wid}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-05

function result = rad (x)

m = mid (x);
## The midpoint is rounded to nearest and the radius must cover both boundaries
fesetround (inf);
r1 = m - x.inf;
r2 = x.sup - m;
fesetround (0.5);
result = max (r1, r2);

result (isempty (x)) = nan ();

return