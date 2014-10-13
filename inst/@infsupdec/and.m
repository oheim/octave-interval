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
## @deftypefn {Interval Function} {@var{C} =} @var{A} & @var{B}
## @cindex IEEE1788 intersection
## 
## Intersect two intervals.
##
## Accuracy: The result is exact.
##
## @example
## @group
## x = infsupdec (1, 3);
## y = infsupdec (2, 4);
## x & y
##   @result{} [2, 3]_trv
## @end group
## @end example
## @seealso{or}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = and(a, b)

assert (nargin == 2);

## Convert first parameter into interval, if necessary
if (not (isa (a, "infsupdec")))
    a = infsupdec (a);
endif

## Convert second parameter into interval, if necessary
if (not (isa (b, "infsupdec")))
    b = infsupdec (b);
endif

result = and (intervalpart (a), intervalpart (b));
## intersection must not retain any useful decoration
result = decorateresult (result, {a, b}, "trv");

endfunction