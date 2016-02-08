## Copyright 2014-2016 Oliver Heimlich
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
## @documentencoding UTF-8
## @defop Method {@@infsupdec} minus (@var{X}, @var{Y})
## @defopx Operator {@@infsupdec} {@var{X} - @var{Y}}
## 
## Subtract all numbers of interval @var{Y} from all numbers of @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsupdec (2, 3);
## y = infsupdec (1, 2);
## x - y
##   @result{} ans = [0, 2]_com
## @end group
## @end example
## @seealso{@@infsupdec/plus}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = minus (x, y)

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

result = newdec (minus (intervalpart (x), intervalpart (y)));
## minus is defined and continuous everywhere
result.dec = min (result.dec, min (x.dec, y.dec));

endfunction

%!test "from the documentation string";
%! assert (isequal (infsupdec (2, 3) - infsupdec (1, 2), infsupdec (0, 2)));
