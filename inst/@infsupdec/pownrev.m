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
## @deftypefn {Interval Function} {@var{X} =} pownrev (@var{C}, @var{X}, @var{P})
## @deftypefnx {Interval Function} {@var{X} =} pownrev (@var{C}, @var{P})
## @cindex IEEE1788 pownRev
## 
## Compute the reverse monomial @code{x^@var{P}}.
##
## Accuracy: The result is a valid enclosure.  The result is a tight
## enclosure for @var{P} in @{-1, 0, 1, 2@}.  The result is an accurate
## enclosure in cases where @code{recip (infsup (@var{P}))} is a singleton.
##
## @seealso{pown}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = pownrev (c, x, p)

assert (nargin >= 2)

if (nargin < 3)
    p = x;
    x = infsupdec (-inf, inf);
endif

## Convert first parameter into interval, if necessary
if (not (isa (c, "infsupdec")))
    c = infsupdec (c);
endif

## Convert second parameter into interval, if necessary
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

result = pownrev (intervalpart (c), intervalpart (x), p);
if (rem (p, 2) ~= 0 || inf (x) >= 0 || sup (x) <= 0)
    ## For this restriction of x's domain, the reverse function is a continuous
    ## point function
    result = decorateresult (result, {x});
else
    ## reverse function can't be decorated, it is not a point function
    result = setdec (result, "trv");
endif

endfunction