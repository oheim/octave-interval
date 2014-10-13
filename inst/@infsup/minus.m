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
## @deftypefn {Interval Function} {@var{Z} =} @var{X} - @var{Y}
## @cindex IEEE1788 sub
## 
## Subtract all numbers of interval @var{Y} from all numbers of @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## x - y
##   @result{} [0, 2]
## @end group
## @end example
## @seealso{plus}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = minus (x, y)

assert (nargin == 2);

## Convert first parameter into interval, if necessary
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

## Convert subtrahend into interval, if necessary
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

if (isempty (x) || isempty (y))
    result = infsup ();
    return
endif

fesetround (-inf);
dif.inf = x.inf - y.inf;
fesetround (inf);
dif.sup = x.sup - y.sup;
fesetround (0.5);

result = infsup (dif.inf, dif.sup);

endfunction