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
## @documentencoding utf-8
## @deftypefn {Function File} {@var{Y} =} pown (@var{X}, @var{P})
## 
## Compute the monomial @code{x^@var{P}} for all numbers in @var{X}.
##
## Monomials are defined for all real numbers and the special monomial
## @code{@var{P} == 0} evaluates to @code{1} everywhere.
##
## Accuracy: The result is a tight enclosure.
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

if (nargin ~= 2)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (pown (intervalpart (x), p));
result.dec = mindec (result.dec, x.dec);

## x^P is undefined for x == 0 and P < 0
domain = p >= 0 | not (ismember (0, x));
result.dec (not (domain)) = "trv";

endfunction