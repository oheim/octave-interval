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
## @deftypefn {Interval Function} {@var{Y} =} powrev2 (@var{A}, @var{C}, @var{Y})
## @deftypefnx {Interval Function} {@var{Y} =} powrev2 (@var{A}, @var{C})
## @cindex IEEE1788 powRev2
## 
## Compute the reverse power function with
## @code{pow (@var{A}, @var{Y}) = @var{C}}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## powrev2 (infsupdec (2, 5), infsupdec (3, 6))
##   @result{} [.6826061944859851, 2.584962500721157]_trv
## @end group
## @end example
## @seealso{pow}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = powrev2 (a, c, y)

if (nargin < 2)
    print_usage ();
    return
endif
if (nargin < 3)
    y = infsupdec (-inf, inf);
endif
if (not (isa (a, "infsupdec")))
    a = infsupdec (a);
endif
if (not (isa (c, "infsupdec")))
    c = infsupdec (c);
endif
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif

if (isnai (y))
    result = y;
    return
endif
if (isnai (a))
    result = b;
    return
endif
if (isnai (c))
    result = c;
    return
endif

result = powrev2 (intervalpart (a), intervalpart (c), intervalpart (y));
## inverse power is not a point function
result = infsupdec (result, "trv");

endfunction
