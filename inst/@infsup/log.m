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
## @deftypefn {Interval Function} {} log (@var{X})
## @cindex IEEE1788 log
## 
## Compute the natural logarithm for all numbers in interval @var{X}.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## log (infsup (2))
##   @result{} [.6931471805599451, .6931471805599454]
## @end group
## @end example
## @seealso{exp, log2, log10}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = log (x)

l = ulpadd (real (log (x.inf)), -1);
u = ulpadd (real (log (x.sup)), 1);

l (x.inf <= 0) = -inf;
l (x.inf == 1) = 0;
u (x.sup == 1) = 0;

emptyresult = isempty (x) | x.sup <= 0;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction