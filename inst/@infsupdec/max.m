## Copyright 2014-2015 Oliver Heimlich
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
## @documentencoding utf-8
## @deftypefn {Function File} {} max (@var{X}, @var{Y})
## 
## Compute the maximum value for each pair of numbers chosen from intervals
## @var{X} and @var{Y}.
##
## Evaluated on interval matrices, this functions is applied element-wise.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsupdec (2, 3);
## y = infsupdec (1, 2);
## max (x, y)
##   @result{} [2, 3]_com
## @end group
## @end example
## @seealso{@@infsupdec/min}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = max (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif

if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif
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

result = infsupdec (max (intervalpart (x), intervalpart (y)));
## max is defined and continuous everywhere
result.dec = mindec (result.dec, x.dec, y.dec);

endfunction