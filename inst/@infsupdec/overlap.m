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
## @deftypefn {Function File} {[@var{STATE}, @var{BITMASK}] =} overlap(@var{A}, @var{B})
## 
## Extensively compare the positions of intervals @var{A} and @var{B} on the
## real number line.  Return the @var{STATE} as a string, e. g.,
## @code{bothEmpty} or @code{before}.  Return the @var{BITMASK} of the state as
## an uint16 number, which represents one of the 16 possible states by taking a
## value 2^i (i = 0 .. 15).
##
## Evaluated on interval matrices, this functions is applied element-wise.
##
## @seealso{eq, subset, interior, disjoint}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function [state, bitmask] = overlap (a, b)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (a, "infsupdec")))
    a = infsupdec (a);
endif
if (not (isa (b, "infsupdec")))
    b = infsupdec (b);
endif

if (isnai (a) || isnai (b))
    error ("interval comparison with NaI")
endif

[state, bitmask] = overlap (intervalpart (a), intervalpart (b));

endfunction