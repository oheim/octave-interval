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
## @defmethod {@@infsup} union (@var{A})
## @defmethodx {@@infsup} union (@var{A}, @var{B})
## @defmethodx {@@infsup} union (@var{A}, [], @var{DIM})
## 
## Build the interval hull of the union of intervals.
##
## With two arguments the union is built pair-wise.  Otherwise the union is
## computed for all interval members along dimension @var{DIM}, which defaults
## to the first non-singleton dimension.
##
## Accuracy: The result is exact.
##
## @example
## @group
## x = infsup (1, 3);
## y = infsup (2, 4);
## union (x, y)
##   @result{} ans = [1, 4]
## @end group
## @end example
## @seealso{@@infsup/intersect, @@infsup/setdiff, @@infsup/setxor}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-02

function result = union (a, b, dim)

if (not (isa (a, "infsup")))
    a = infsup (a);
endif

switch (nargin)
    case 1
        l = min (a.inf);
        u = max (a.sup);
    case 2
        if (not (isa (b, "infsup")))
            b = infsup (b);
        endif
        l = min (a.inf, b.inf);
        u = max (a.sup, b.sup);
    case 3
        if (not (builtin ("isempty", b)))
            warning ("union: second argument is ignored");
        endif
        l = min (a.inf, [], dim);
        u = max (a.sup, [], dim);
    otherwise
        print_usage ();
        return
endswitch

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (union (infsup (1, 3), infsup (2, 4)) == infsup (1, 4));
