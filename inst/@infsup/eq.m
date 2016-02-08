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
## @defop Method {@@infsup} eq (@var{A}, @var{B})
## @defopx Operator {@@infsup} {@var{A} == @var{B}}
## 
## Compare intervals @var{A} and @var{B} for equality.
##
## True, if all numbers from @var{A} are also contained in @var{B} and vice
## versa.  False, if @var{A} contains a number which is not a member in @var{B}
## or vice versa.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## x == y
##   @result{} ans =  0
## @end group
## @end example
## @seealso{@@infsup/subset, @@infsup/interior, @@infsup/disjoint}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = eq (a, b)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (a, "infsup")))
    a = infsup (a);
endif
if (not (isa (b, "infsup")))
    b = infsup (b);
elseif (isa (b, "infsupdec"))
    ## Workaround for bug #42735
    result = eq (a, b);
    return
endif

result = (a.inf == b.inf & a.sup == b.sup);

endfunction

%!test "Empty interval";
%! assert (eq (infsup (), infsup ()) == true);
%! assert (eq (infsup (), infsup (1)) == false);
%! assert (eq (infsup (0), infsup ()) == false);
%! assert (eq (infsup (-inf, inf), infsup ()) == false);
%!test "Singleton intervals";
%! assert (eq (infsup (0), infsup (1)) == false);
%! assert (eq (infsup (0), infsup (0)) == true);
%!test "Bounded intervals";
%! assert (eq (infsup (1, 2), infsup (3, 4)) == false);
%! assert (eq (infsup (1, 2), infsup (2, 3)) == false);
%! assert (eq (infsup (1, 2), infsup (1.5, 2.5)) == false);
%! assert (eq (infsup (1, 2), infsup (1, 2)) == true);
%!test "Unbounded intervals";
%! assert (eq (infsup (0, inf), infsup (-inf, 0)) == false);
%! assert (eq (infsup (0, inf), infsup (0, inf)) == true);
%! assert (eq (infsup (-inf, 0), infsup (-inf, 0)) == true);
%! assert (eq (infsup (-inf, inf), infsup (42)) == false);
%! assert (eq (infsup (-inf, 0), infsup (-inf, inf)) == false);
%! assert (eq (infsup (-inf, inf), infsup (-inf, inf)) == true);
