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
## @deftypefn {Interval Comparison} {} strictprecedes (@var{A}, @var{B})
## @cindex IEEE1788 strictPrecedes
## 
## Evaluate strict precedes comparison on intervals.
##
## True, if @var{A} is strictly left of @var{B}. The intervals may not touch.
##
## Evaluated on interval matrices, this functions is applied element-wise.
##
## @seealso{eq, le, lt, gt, precedes, subset, interior, disjoint}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = strictprecedes (a, b)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (a, "infsup")))
    a = infsup (a);
endif
if (not (isa (b, "infsup")))
    b = infsup (b);
endif

result = (a.sup < b.inf);

result (isempty (a) | isempty (b)) = true ();

endfunction