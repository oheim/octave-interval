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
## @deftypefn {Function File} {@var{X} =} sqrrev (@var{C}, @var{X})
## @deftypefnx {Function File} {@var{X} =} sqrrev (@var{C})
## 
## Compute the reverse square function.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sqrrev (infsup (-2, 1))
##   @result{} [-1, 1]
## @end group
## @end example
## @seealso{@@infsup/sqr}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = sqrrev (c, x)

if (nargin > 2)
    print_usage ();
    return
endif

if (nargin < 2)
    x = infsup (-inf, inf);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

p = sqrt (c);
n = - p;

result = (p & x) | (n & x);

endfunction
