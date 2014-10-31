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

## @deftypefn {Interval Constructor} {} subsasgn (@var{A}, @var{IDX}, @var{RHS})
##
## Perform the subscripted assignment operation according to the subscript
## specified by @var{IDX}.
##
## The subscript @var{IDX} is expected to be a structure array with fields
## @code{type} and @code{subs}.  Only valid value for @var{type} is
## @code{"()"}.  The @code{subs} field may be either @code{":"} or a cell array
## of index values.
## @seealso{subsref}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

function result = subsasgn (A, S, B)

if (nargin ~= 3)
    print_usage ();
    return
endif
if (not (isa (A, "infsup")))
    A = infsup (A);
endif
if (not (isa (B, "infsup")))
    B = infsup (B);
endif

assert (strcmp (S.type, "()"), "only subscripts with parenthesis allowed");

l = subsasgn (A.inf, S, B.inf);
u = subsasgn (A.sup, S, B.sup);

## Implicit new elements in the matrices take the value 0. We can detect them
## in the inf matrix, because zeros in the inf matrix are set to -0 by the
## infsup constructor.

newelements = not (signbit (A.inf)) & (A.inf == 0);

## Set the implicit new elements to [Empty].
l (newelements) = inf;
u (newelements) = -inf;

result = infsup (l, u);
 
endfunction