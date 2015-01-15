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
## Created: 2014-11-02

function result = subsasgn (A, S, B)

if (nargin ~= 3)
    print_usage ();
    return
endif
if (not (isa (A, "infsupdec")))
    A = infsupdec (A);
endif
if (not (isa (B, "infsupdec")))
    B = infsupdec (B);
endif

if (isnai (A))
    result = A;
    return
endif
if (isnai (B))
    result = B;
    return
endif

x = subsasgn (intervalpart (A), S, intervalpart (B));
dx = subsasgn (A.dec, S, B.dec);

## Implicit new elements carry the value [Empty] and must be initialized with
## decoration trv.  Old elements that have been [Empty] before, already have
## the decoration trv.
dx (isempty (x)) = "trv";

result = infsupdec (x, dx);
 
endfunction