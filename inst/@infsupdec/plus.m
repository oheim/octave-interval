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
## @deftypefn {Interval Function} {@var{Z} =} @var{X} + @var{Y}
## @cindex IEEE1788 add
## 
## Add all numbers of interval @var{X} to all numbers of @var{Y}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsupdec (2, 3);
## y = infsupdec (1, 2);
## x + y
##   @result{} [3, 5]_com
## @end group
## @end example
## @seealso{minus}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = plus (x, y)

assert (nargin == 2);

## Convert first parameter into decorated interval, if necessary
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

## Convert addend into decorated interval, if necessary
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif

if (isnai (x))
    result = x;
    return
endif

if (isnai (y))
    result = y;
    return
endif

result = plus (intervalpart (x), intervalpart (y));
## plus is continous and defined everywhere
result = decorateresult (result, {x, y});

endfunction