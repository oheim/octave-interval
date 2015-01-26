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
## @documentencoding utf-8
## @deftypefn {Function File} {@var{X} =} sinrev (@var{C}, @var{X})
## @deftypefnx {Function File} {@var{X} =} sinrev (@var{C})
## 
## Compute the reverse sine function.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## sinrev (infsupdec (-1), infsupdec (0, 6))
##   @result{} [4.7123889803846896, 4.7123889803846906]_trv
## @end group
## @end example
## @seealso{@@infsupdec/sin}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = sinrev (c, x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (nargin < 2)
    x = infsupdec (-inf, inf);
endif
if (not (isa (c, "infsupdec")))
    c = infsupdec (c);
endif
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

if (isnai (c))
    result = c;
    return
endif
if (isnai (x))
    result = x;
    return
endif

pi = infsup ("pi");

result = infsupdec (sinrev (intervalpart (c), intervalpart (x)));
result.dec = mindec (result.dec, x.dec);

## For this restriction of x's domain, the reverse function is a continuous
## point function
pointfunction = ceil (floor (sup (sup (x) / (pi / 2))) / 2) == ...
                floor (ceil (inf (inf (x) / (pi / 2))) / 2);
result.dec (not (pointfunction)) = "trv";

endfunction