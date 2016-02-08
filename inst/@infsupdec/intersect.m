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
## @defmethod {@@infsupdec} intersect (@var{A})
## @defmethodx {@@infsupdec} intersect (@var{A}, @var{B})
## @defmethodx {@@infsupdec} intersect (@var{A}, [], @var{DIM})
## 
## Intersect intervals.
##
## With two arguments the intersection is built pair-wise.  Otherwise the
## intersection is computed for all interval members along dimension @var{DIM},
## which defaults to the first non-singleton dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## The function is a set operation and the result carries the @code{trv}
## decoration at best.
##
## @example
## @group
## x = infsupdec (1, 3);
## y = infsupdec (2, 4);
## intersect (x, y)
##   @result{} ans = [2, 3]_trv
## @end group
## @end example
## @seealso{@@infsupdec/union, @@infsupdec/setdiff, @@infsupdec/setxor}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = intersect (a, b, dim)

if (not (isa (a, "infsupdec")))
    a = infsupdec (a);
endif

if (isnai (a))
    result = a;
    return
endif

switch (nargin)
    case 1
        bare = intersect (intervalpart (a));
    case 2
        if (not (isa (b, "infsupdec")))
            b = infsupdec (b);
        endif
        if (isnai (b))
            result = b;
            return
        endif
        bare = intersect (intervalpart (a), intervalpart (b));
    case 3
        if (not (builtin ("isempty", b)))
            warning ("intersect: second argument is ignored");
        endif
        bare = intersect (intervalpart (a), [], dim);
    otherwise
        print_usage ();
        return
endswitch

## intersection must not retain any useful decoration
result = infsupdec (bare, "trv");

endfunction

%!test "from the documentation string";
%! assert (isequal (intersect (infsupdec (1, 3), infsupdec (2, 4)), infsupdec (2, 3, "trv")));
