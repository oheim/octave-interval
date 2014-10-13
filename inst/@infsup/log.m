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
## @deftypefn {Interval Function} {@var{Y} =} log (@var{X})
## @cindex IEEE1788 log
## 
## Compute the natural logarithm for all numbers in interval @var{X}.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## log (infsup (2))
##   @result{} [.6931471805599452, .6931471805599454]
## @end group
## @end example
## @seealso{exp, log2, log10}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = log (x)

if (isempty (x) || x.sup <= 0)
    result = infsup ();
    return
endif

if (x.inf <= 0)
    l.inf = -inf;
else
    fesetround  (-inf);
    l.inf = log (x.inf);
endif

fesetround (inf);
l.sup = log (x.sup);
fesetround (0.5);

result = infsup (l.inf, l.sup);

endfunction