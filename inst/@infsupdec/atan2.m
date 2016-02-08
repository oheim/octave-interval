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
## @defmethod {@@infsupdec} atan2 (@var{Y}, @var{X})
## 
## Compute the inverse tangent with two arguments.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## atan2 (infsupdec (1), infsupdec (-1))
##   @result{} ans ⊂ [2.3561, 2.3562]_com
## @end group
## @end example
## @seealso{@@infsupdec/tan}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = atan2 (y, x)

if (nargin ~= 2)
    print_usage ();
    return
endif

if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

if (isnai (x))
    result = x;
    return
endif
if (isnai (y))
    result = y;
    return
endif

result = newdec (atan2 (intervalpart (y), intervalpart (x)));
result.dec = min (result.dec, min (y.dec, x.dec));

## The function is discontinuous for x <= 0 and y == 0
discontinuos = inf (y) < 0 & sup (y) >= 0 & inf (x) < 0;
result.dec (discontinuos) = min (result.dec (discontinuos), _def ());

## For y = [0, y.sup] the function is discontinuous, but its restriction is not
onlyrestrictioncontinuous = inf (y) == 0 & inf (x) < 0;
result.dec (onlyrestrictioncontinuous) = ...
    min (result.dec (onlyrestrictioncontinuous), _dac ());

## The only undefined input is <0,0>
result.dec (ismember (0, y) & ismember (0, x)) = _trv ();

endfunction

%!test "from the documentation string";
%! assert (isequal (atan2 (infsupdec (1), infsupdec (-1)), infsupdec ("[0x1.2D97C7F3321D2p1, 0x1.2D97C7F3321D3p1]")));
