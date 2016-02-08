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
## @defop Method {@@infsup} subsasgn (@var{A}, @var{IDX}, @var{RHS})
## @defopx Operator {@@infsup} {@var{A}(@var{SUBS}) = @var{RHS}}
##
## Perform the subscripted assignment operation according to the subscript
## specified by @var{IDX}.
##
## The subscript @var{IDX} is expected to be a structure array with fields
## @code{type} and @code{subs}.  Only valid value for @var{type} is
## @code{"()"}.  The @code{subs} field may be either @code{":"} or a cell array
## of index values.
## @seealso{@@infsup/subsref}
## @end defop

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
elseif (isa (B, "infsupdec"))
    ## Workaround for bug #42735
    result = subsasgn (A, S, B);
    return
endif

assert (strcmp (S.type, "()"), "only subscripts with parenthesis allowed");

l = subsasgn (A.inf, S, B.inf);
u = subsasgn (A.sup, S, B.sup);

result = infsup (l, u);
 
endfunction

%!test
%! A = infsup (magic (3));
%! A (4, 4) = 42;
%! assert (inf (A), [magic(3),[0;0;0];0,0,0,42]);
%! assert (sup (A), [magic(3),[0;0;0];0,0,0,42]);
