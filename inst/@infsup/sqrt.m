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
## @deftypefn {Interval Function} {@var{Y} =} sqrt (@var{X})
## @cindex IEEE1788 sqrt
## 
## Compute the square root for all non-negative numbers in @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sqrt (infsup (-6, 4))
##   @result{} [0, 2]
## @end group
## @end example
## @seealso{sqr, pow}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-01

function result = sqrt (x)

if (isempty (x) || x.sup < 0)
    result = infsup ();
    return
endif

if (x.inf <= 0)
    root.inf = 0;
else
    fesetround (-inf);
    root.inf = realsqrt (x.inf);
endif
fesetround (inf);
root.sup = realsqrt (x.sup);

fesetround (0.5);
result = infsup (root.inf, root.sup);

endfunction