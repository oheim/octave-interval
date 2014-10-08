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
## @deftypefn {Interval Comparison} {[@var{STATE}, @var{BITMASK}] =} overlap(@var{A}, @var{B})
## @cindex IEEE1788 overlap
## 
## Extensively compare the positions of intervals @var{A} and @var{B} on the
## real number line.  Return the @var{STATE} as a string, e. g.,
## @code{bothEmpty} or @code{before}.  Return the @var{BITMASK} of the state as
## an uint16 number, which represents one of the 16 possible states by taking a
## value 2^i (i = 0 .. 15).
##
## @seealso{eq, subset, interior, disjoint}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function [state, bitmask] = overlap (a, b)

assert (nargin == 2);

if (isempty (a) && isempty (b))
    state = "bothEmpty";
    bitmask = uint16 (pow2 (15));
    return
endif

if (isempty (a))
    state = "firstEmpty";
    bitmask = uint16 (pow2 (14));
    return
endif

if (isempty (b))
    state = "secondEmpty";
    bitmask = uint16 (pow2 (13));
    return
endif

if (a.sup < b.inf)
    state = "before";
    bitmask = uint16 (pow2 (12));
    return
endif

if (a.inf < a.sup && a.sup == b.inf && b.inf < b.sup)
    state = "meets";
    bitmask = uint16 (pow2 (11));
    return
endif

if (a.inf < b.inf && b.inf < a.sup && a.sup < b.sup)
    state = "overlaps";
    bitmask = uint16 (pow2 (10));
    return
endif

if (a.inf == b.inf && a.sup < b.sup)
    state = "starts";
    bitmask = uint16 (pow2 (9));
    return
endif

if (b.inf < a.inf && a.sup < b.sup)
    state = "containedBy";
    bitmask = uint16 (pow2 (8));
    return
endif

if (b.inf < a.inf && a.sup == b.sup)
    state = "finishes";
    bitmask = uint16 (pow2 (7));
    return
endif

if (a.inf == b.inf && a.sup == b.sup)
    state = "equal";
    bitmask = uint16 (pow2 (6));
    return
endif

if (a.inf < b.inf && b.sup == a.sup)
    state = "finishedBy";
    bitmask = uint16 (pow2 (5));
    return
endif

if (a.inf < b.inf && b.sup < a.sup)
    state = "contains";
    bitmask = uint16 (pow2 (4));
    return
endif

if (b.inf == a.inf && b.sup < a.sup)
    state = "startedBy";
    bitmask = uint16 (pow2 (3));
    return
endif

if (b.inf < a.inf && a.inf < b.sup && b.sup < a.sup)
    state = "overlappedBy";
    bitmask = uint16 (pow2 (2));
    return
endif

if (b.inf < b.sup && b.sup = a.inf && a.inf < a.sup)
    state = "metBy";
    bitmask = uint16 (pow2 (1));
    return
endif

if (b.sup < a.inf)
    state = "after";
    bitmask = uint16 (pow2 (0));
    return
endif

assert (false);

endfunction