## Copyright 2015-2016 Oliver Heimlich
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
## @deftypemethod {@@infsupdec} {@var{x} =} gauss (@var{A}, @var{b})
## 
## Solve a linear interval system @var{A} * @var{x} = @var{b} using Gaussian
## elimination.
##
## The found enclosure is improved with the help of the Gauß-Seidel-method.
##
## Note: This algorithm is very inaccurate and slow for matrices of a dimension 
## greater than 3.  A better solver is provided by @code{mldivide}.  The
## inaccuracy mainly comes from the dependency problem of interval arithmetic
## during back-substitution of the solution's enclosure.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## gauss (infsupdec ([1, 0; 0, 2]), [2, 0; 0, 4])
##   @result{} ans = 2×2 interval matrix
##      [2]_trv   [0]_trv
##      [0]_trv   [2]_trv
## @end group
## @end example
## @seealso{@@infsupdec/mldivide}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-18

function result = gauss (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif

if (isnai (x))
    result = x;
    return
endif
if (isnai (y))
    result = y;
    return
endif

result = infsupdec (gauss (intervalpart (x), intervalpart (y)), "trv");

endfunction

%!xtest "from the documentation string";
%! assert (isequal (gauss (infsupdec ([1, 0; 0, 2]), [2, 0; 0, 4]), infsupdec ([2, 0; 0, 2], "trv")));
