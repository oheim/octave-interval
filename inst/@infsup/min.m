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
## @deftypefn {Interval Function} {@var{Z} =} min (@var{X}, @var{Y})
## @cindex IEEE1788 min
## 
## Compute the minimum value for each pair of numbers chosen from intervals
## @var{X} and @var{Y}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## min (x, y)
##   @result{} [1 , 2]
## @end group
## @end example
## @seealso{min}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = min (x, y)

if (isempty (x) || isempty (y))
    result = empty ();
    return
endif

result = infsup (min (x.inf, y.inf), min (x.sup, y.sup));

endfunction