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
## @defop Method {@@infsupdec} eq (@var{A}, @var{B})
## @defopx Operator {@@infsupdec} {@var{A} == @var{B}}
## 
## Compare intervals @var{A} and @var{B} for equality.
##
## True, if all numbers from @var{A} are also contained in @var{B} and vice
## versa.  False, if @var{A} contains a number which is not a member in @var{B}
## or vice versa.
##
## @example
## @group
## x = infsupdec (2, 3);
## y = infsupdec (1, 2);
## x == y
##   @result{} ans =  0
## @end group
## @end example
## @seealso{@@infsupdec/subset, @@infsupdec/interior, @@infsupdec/disjoint}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = eq (a, b)

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
    result = false ();
else
    result = eq (intervalpart (a), intervalpart (b));
endif

endfunction

%!test "Empty interval";
%! assert (eq (infsupdec (), infsupdec ()) == true);
%! assert (eq (infsupdec (), infsupdec (1)) == false);
%! assert (eq (infsupdec (0), infsupdec ()) == false);
%! assert (eq (infsupdec (-inf, inf), infsupdec ()) == false);
%!test "Singleton intervals";
%! assert (eq (infsupdec (0), infsupdec (1)) == false);
%! assert (eq (infsupdec (0), infsupdec (0)) == true);
%!test "Bounded intervals";
%! assert (eq (infsupdec (1, 2), infsupdec (3, 4)) == false);
%! assert (eq (infsupdec (1, 2), infsupdec (2, 3)) == false);
%! assert (eq (infsupdec (1, 2), infsupdec (1.5, 2.5)) == false);
%! assert (eq (infsupdec (1, 2), infsupdec (1, 2)) == true);
%!test "Unbounded intervals";
%! assert (eq (infsupdec (0, inf), infsupdec (-inf, 0)) == false);
%! assert (eq (infsupdec (0, inf), infsupdec (0, inf)) == true);
%! assert (eq (infsupdec (-inf, 0), infsupdec (-inf, 0)) == true);
%! assert (eq (infsupdec (-inf, inf), infsupdec (42)) == false);
%! assert (eq (infsupdec (-inf, 0), infsupdec (-inf, inf)) == false);
%! assert (eq (infsupdec (-inf, inf), infsupdec (-inf, inf)) == true);
