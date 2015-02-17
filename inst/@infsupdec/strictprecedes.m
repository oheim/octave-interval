## Copyright 2014-2015 Oliver Heimlich
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
## @deftypefn {Function File} {} strictprecedes (@var{A}, @var{B})
## 
## Evaluate strict precedes comparison on intervals.
##
## True, if @var{A} is strictly left of @var{B}. The intervals may not touch.
##
## Evaluated on interval matrices, this functions is applied element-wise.
##
## @seealso{@@infsupdec/eq, @@infsupdec/le, @@infsupdec/lt, @@infsupdec/gt, @@infsupdec/precedes, @@infsupdec/subset, @@infsupdec/interior, @@infsupdec/disjoint}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = strictprecedes (a, b)

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
    result = strictprecedes (intervalpart (a), intervalpart (b));
endif

endfunction
