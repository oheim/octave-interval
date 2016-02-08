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
## @defmethod {@@infsupdec} min (@var{X})
## @defmethodx {@@infsupdec} min (@var{X}, @var{Y})
## @defmethodx {@@infsupdec} min (@var{X}, [], @var{DIM})
## 
## Compute the minimum value chosen from intervals.
##
## This function does not return the least element of the interval (see
## @code{inf}), but returns an interval enclosure of the function:
## @display
## min (@var{x}, @var{y}) = ( (x + y) - abs (x - y) ) / 2
## @end display
##
## With two arguments the function is applied element-wise.  Otherwise the
## minimum is computed for all interval members along dimension @var{DIM},
## which defaults to the first non-singleton dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsupdec (2, 3);
## y = infsupdec (1, 2);
## min (x, y)
##   @result{} ans = [1, 2]_com
## @end group
## @end example
## @seealso{@@infsupdec/max}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = min (x, y, dim)

if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

if (isnai (x))
    result = x;
    return
endif

switch (nargin)
    case 1
        bare = min (intervalpart (x));
    case 2
        if (not (isa (y, "infsupdec")))
            y = infsupdec (y);
        endif
        if (isnai (y))
            result = y;
            return
        endif
        bare = min (intervalpart (x), intervalpart (y));
    case 3
        if (not (builtin ("isempty", y)))
            warning ("min: second argument is ignored");
        endif
        bare = min (intervalpart (x), [], dim);
    otherwise
        print_usage ();
        return
endswitch

result = newdec (bare);
## min is defined and continuous everywhere
switch (nargin)
    case 1
        result.dec = min (result.dec, min (x.dec));
    case 2
        result.dec = min (result.dec, min (x.dec, y.dec));
    case 3
        result.dec = min (result.dec, min (x.dec, [], dim));
endswitch

endfunction

%!test "from the documentation string";
%! assert (isequal (min (infsupdec (2, 3), infsupdec (1, 2)), infsupdec (1, 2)));
