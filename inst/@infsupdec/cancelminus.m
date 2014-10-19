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
## @deftypefn {Interval Function} {@var{Z} =} cancelminus (@var{X}, @var{Y})
## @cindex IEEE1788 cancelMinus
## 
## Recover interval @var{Z} from intervals @var{X} and @var{Y}, given that one
## knows @var{X} was obtained as the sum @var{Y} + @var{Z}.
##
## Accuracy: The result is a tight enclosure.
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = cancelminus (x, y)

assert (nargin == 2);

## Convert first parameter into interval, if necessary
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

## Convert divisor into interval, if necessary
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif

if (isnai (x))
    result = x;
    return
endif

if (isnai (y))
    result = y;
    return;
endif

result = cancelminus (intervalpart (x), intervalpart (y));
## cancelMinus must not retain any useful decoration
result = decorateresult (result, {x, y}, "trv");

endfunction