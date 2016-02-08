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
## @defmethod {@@infsupdec} disjoint (@var{A}, @var{B})
## 
## Evaluate disjoint comparison on intervals.
##
## True, if all numbers from @var{A} are not contained in @var{B} and vice
## versa.  False, if @var{A} and @var{B} have at least one element in common.
##
## Evaluated on interval matrices, this functions is applied element-wise.
##
## @seealso{@@infsupdec/eq, @@infsupdec/subset, @@infsupdec/interior}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = disjoint (a, b)

if (nargin ~= 2)
    print_usage ();
    return
endif

if (not (isa (a, "infsupdec")))
    a = infsupdec (a);
endif
if (not (isa (b, "infsupdec")))
    b = infsupdec (b);
endif

if (isnai (a) || isnai (b))
    result = false ();
else
    result = disjoint (intervalpart (a), intervalpart (b));
endif

endfunction

%!assert (disjoint (infsupdec (3, 4), infsupdec (5, 6)));
%!assert (not (disjoint (infsupdec (3, 4), infsupdec (4, 5))));
