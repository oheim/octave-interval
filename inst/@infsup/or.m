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
## @deftypefn {Interval Function} {@var{C} =} @var{A} | @var{B}
## @cindex IEEE1788 convexHull
## 
## Build the interval hull of the union of two intervals.
##
## Accuracy: The result is exact.
##
## @example
## @group
## x = infsup (1, 3);
## y = infsup (2, 4);
## x | y
##   @result{} [1, 4]
## @end group
## @end example
## @seealso{or}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-02

function result = or(a, b)

## Convert second parameter into interval, if necessary
if (not (isa (b, "infsup")))
    b = infsup (b);
endif

if (isempty (a) || isentire (b))
    result = b;
    return
endif

if (isempty (b) || isentire (a))
    result = a;
    return
endif

result = infsup (min (a.inf, b.inf), max (a.sup, b.sup));

endfunction