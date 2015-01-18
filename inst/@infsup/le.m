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
## @deftypefn {Function File} {} {} @var{A} <= @var{B}
## 
## Compare intervals @var{A} and @var{B} for weakly less.
##
## True, if all numbers from @var{A} are weakly less than any number in
## @var{B}.  False, if @var{A} contains a number which is strictly greater than
## all numbers in @var{B}.
##
## Evaluated on interval matrices, this functions is applied element-wise.
##
## @seealso{eq, lt, ge, subset, interior, disjoint}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = le (a, b)

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

result = (a.inf <= b.inf & a.sup <= b.sup);

endfunction
