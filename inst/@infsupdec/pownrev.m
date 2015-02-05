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
## @deftypefn {Function File} {@var{X} =} pownrev (@var{C}, @var{X}, @var{P})
## @deftypefnx {Function File} {@var{X} =} pownrev (@var{C}, @var{P})
## 
## Compute the reverse monomial @code{x^@var{P}}.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{pown (x, @var{P}) ∈ @var{C}}.
##
## Accuracy: The result is a valid enclosure.  The result is a tight
## enclosure for @var{P} in @{-1, 0, 1, 2@}.  The result is an accurate
## enclosure in cases where @code{recip (infsup (@var{P}))} is a singleton.
##
## @seealso{@@infsupdec/pown}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = pownrev (c, x, p)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif

if (nargin < 3)
    p = x;
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

result = infsupdec (pownrev (intervalpart (c), intervalpart (x), p));
result.dec = mindec (result.dec, x.dec);

## For this restriction of x's domain, the reverse function is a continuous
## point function
pointfunction = rem (p, 2) ~= 0 | inf (x) >= 0 | sup (x) <= 0;
result.dec (not (pointfunction)) = "trv";

endfunction