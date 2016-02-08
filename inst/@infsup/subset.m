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
## @defmethod {@@infsup} subset (@var{A}, @var{B})
## 
## Evaluate subset comparison on intervals.
##
## True, if all numbers from @var{A} are also contained in @var{B}.
## False, if @var{A} contains a number which is not a member in @var{B}.
##
## Evaluated on interval matrices, this functions is applied element-wise.
##
## @seealso{@@infsup/eq, @@infsup/interior, @@infsup/disjoint}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = subset (a, b)

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

result = (b.inf <= a.inf & a.sup <= b.sup);

endfunction

%!assert (subset (infsup (1, 2), infsup (1, 3)));
