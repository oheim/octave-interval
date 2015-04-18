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
## @deftypefn {Function File} {} {} hypot (@var{X}, @var{Y})
## 
## Compute the euclidean norm.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsupdec (2, 3);
## y = infsupdec (1, 2);
## hypot (x, y)
##   @result{} [2.236067977499789, 3.6055512754639896]_com
## @end group
## @end example
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-20

function result = hypot (x, y)

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

result = newdec (hypot (intervalpart (x), intervalpart (y)));
## hypot is continuous and defined everywhere
result.dec = min (result.dec, min (x.dec, y.dec));

endfunction

%!test "from the documentation string";
%! assert (isequal (hypot (infsupdec (2, 3), infsupdec (1, 2)), infsupdec ("[0x1.1E3779B97F4A7p1, 0x1.CD82B446159F4p1]")));
