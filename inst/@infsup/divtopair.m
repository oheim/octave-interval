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
## @deftypefn {Interval Function} {[@var{U}, @var{V} =} divtopair (@var{X}, @var{Y})
## @cindex IEEE1788 divToPair
## 
## Divide all numbers of interval @var{X} by all numbers of @var{Y}.  If the 
## set division of the intervals would be a union of two disjoint intervals,
## this function returns an enclosure of both intervals separately.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (1);
## y = infsup (-inf, inf);
## [u, v] = divtopair (x, y)
##   @result{} [-Inf, 0]
##   @result{} [0, Inf]
## @end group
## @end example
## @seealso{mrdivide}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function [u, v] = divtopair (x, y)

assert (nargin == 2);

## Convert first parameter into interval, if necessary
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

## Convert divisor into interval, if necessary
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

if (y.inf < 0 && 0 < y.sup)
    u = x / infsup (y.inf, 0);
    v = x / infsup (0, y.sup);
else
    u = x / y;
    v = infsup ();
endif

endfunction