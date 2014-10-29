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

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

function A = subsasgn (A, S, B)

assert (nargin == 3);

if (not (isa (A, "infsup")))
    A = infsup (A);
endif
if (not (isa (B, "infsup")))
    B = infsup (B);
endif

A.inf = subsasgn (A.inf, S, B.inf);
A.sup = subsasgn (A.sup, S, B.sup);

## Implicit new elements in the matrices take the value 0. We can detect them
## in the inf matrix, because zeros in the inf matrix are set to -0 by the
## infsup constructor.

newelements = not (signbit (A.inf)) & (A.inf == 0);

## Set the implicit new elements to [Empty].
A.inf (newelements) = inf;
A.sup (newelements) = -inf;
 
endfunction