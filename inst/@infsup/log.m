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
## @deftypefn {Function File} {} log (@var{X})
## 
## Compute the natural logarithm for all numbers in interval @var{X}.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## log (infsup (2))
##   @result{} [.6931471805599452, .6931471805599454]
## @end group
## @end example
## @seealso{exp, log2, log10}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = log (x)

l = mpfr_function_d ('log', -inf, x.inf);
u = mpfr_function_d ('log', +inf, x.sup);

l (x.inf <= 0) = -inf;

emptyresult = isempty (x) | x.sup <= 0;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction