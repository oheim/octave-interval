## Copyright 2015 Oliver Heimlich
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
## @deftypefn {Function File} {} {} @var{X} \ @var{Y}
## 
## Return the interval matrix left division of @var{X} and @var{Y}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## infsupdec ([1, 0; 0, 2]) \ [2, 0; 0, 4]
##   @result{} 2×2 interval matrix
##      [2]_trv   [0]_trv
##      [0]_trv   [2]_trv
## @end group
## @end example
## @seealso{@@infsupdec/mtimes}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-01-31

function result = mldivide (x, y)

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

result = infsupdec (mldivide (intervalpart (x), intervalpart (y)));
## Reverse operations should not carry decoration
result.dec (:) = "trv";

endfunction