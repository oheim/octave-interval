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
## @deftypefn {Interval Function} {@var{Y} =} pown (@var{X}, @var{P})
## @cindex IEEE1788 pown
## 
## Compute the monomial @code{x^@var{P}} for all numbers in @var{X}.
##
## Monomials are defined for all real numbers and the special monomial
## @code{@var{P} == 0} evaluates to @code{1} everywhere.
##
## Accuracy: The result is an accurate enclosure.  The result is tightest in
## each of the following cases:  @var{X} in @{0, 1, 2, 10@}, or @var{P} in
## @{-1, 0.5, 0, 1, 2@}, or @var{X} integral with
## @code{abs (pown (@var{X}, @var{P})) in [2^-53, 2^53]}
##
## @example
## @group
## pown (infsupdec (5, 6), 2)
##   @result{} [25, 36]_com
## @end group
## @end example
## @seealso{pow, pow2, pow10, exp}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = pown (x, p)

assert (nargin == 2);

if (isnai (x))
    result = x;
    return
endif

result = pown (intervalpart (x), p);
if (p < 0 && ismember (0, x))
    ## x^P is undefined for x == 0 and P < 0
    result = decorateresult (result, {x}, "trv");
else
    result = decorateresult (result, {x});
endif

endfunction