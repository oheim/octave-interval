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
## @deftypemethod {@@infsupdec} {[@var{STATE}, @var{BITMASK}] =} overlap(@var{A}, @var{B})
## 
## Extensively compare the positions of intervals @var{A} and @var{B} on the
## real number line.
##
## Return the @var{STATE} as a string and the @var{BITMASK} of the state as an
## uint16 number, which represents one of the 16 possible states by taking a
## value 2^i (i = 0 … 15).
##
## Evaluated on interval matrices, this functions is applied element-wise.
##
## @table @asis
## @item @code{bothEmpty}, 2^0
## Both intervals are empty
## @item @code{firstEmpty}, 2^1
## Interval @var{A} is empty and @var{B} is not
## @item @code{secondEmpty}, 2^2
## Interval @var{A} is not empty, but @var{B} is
## @item @code{before}, 2^3
## [- - - @var{A} - - -]@ @ @ [- - - @var{B} - - -]
## @item @code{meets}, 2^4
## [- - - @var{A} - - -][- - - @var{B} - - -]
## @*Interval @var{A}'s upper boundary equals interval @var{B}'s lower boundary
## and neither consists of a single point only.
## @item @code{overlaps}, 2^5
## [- - - @var{A} - - - [= = =] - - - @var{B} - - -]
## @item @code{starts}, 2^6
## [[= = = @var{A} = = =] - - - @var{B} - - -]
## @item @code{containedBy}, 2^7
## [- - - @var{B} - - - [= = = @var{A} = = =] - - -]
## @item @code{finishes}, 2^8
## [- - - @var{B} - - - [= = = @var{A} = = =]]
## @item @code{equals}, 2^9
## Both intervals are equal (and not empty)
## @item @code{finishedBy}, 2^10
## [- - - @var{A} - - - [= = = @var{B} = = =]]
## @item @code{contains}, 2^11
## [- - - @var{A} - - - [= = = @var{B} = = =] - - -]
## @item @code{startedBy}, 2^12
## [[= = = @var{B} = = =] - - - @var{A} - - -]
## @item @code{overlappedBy}, 2^13
## [- - - @var{B} - - - [= = =] - - - @var{A} - - -]
## @item @code{metBy}, 2^14
## [- - - @var{B} - - -][- - - @var{A} - - -]
## @*Interval @var{A}'s lower boundary equals interval @var{B}'s upper boundary
## and neither consists of a single point only.
## @item @code{after}, 2^15
## [- - - @var{B} - - -]@ @ @ [- - - @var{A} - - -]
## @end table
##
## @seealso{@@infsupdec/eq, @@infsupdec/subset, @@infsupdec/interior, @@infsupdec/disjoint}
## @end deftypemethod

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
    error ("interval:InvalidOperand", "interval comparison with NaI")
endif

[state, bitmask] = overlap (intervalpart (a), intervalpart (b));

endfunction

%!assert (overlap (infsupdec (1, 2), infsupdec (3, 4)), "before");
