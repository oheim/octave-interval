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
## @deftypefn {Function File} {[@var{U}, @var{V}] =} mulrevtopair (@var{X}, @var{Y})
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
## [u, v] = mulrevtopair (x, y)
##   @result{} [-Inf, 0]
##   @result{} [0, Inf]
## @end group
## @end example
## @seealso{mrdivide}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function [u, v] = mulrevtopair (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

u = x / (y & infsup (-inf, 0));
v = x / (y & infsup (0, inf));

swap = (y.sup <= 0 | 0 <= y.inf) & isempty (u);
u.inf (swap) = v.inf (swap);
u.sup (swap) = v.sup (swap);
v.inf (swap) = inf;
v.sup (swap) = -inf;

endfunction