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
## @deftypefn {Interval Function} {@var{Y} =} exp (@var{X})
## @cindex IEEE1788 exp
## 
## Compute the exponential function for all numbers in @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## exp (infsup (1))
##   @result{} [2.718281828459045, 2.7182818284590456]
## @end group
## @end example
## @seealso{log, pow}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = exp (x)

l = mpfr_function_d ('exp', -inf, x.inf);
u = mpfr_function_d ('exp', +inf, x.sup);

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction