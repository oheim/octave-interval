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
## @deftypefn {Function File} {} sign (@var{X})
## 
## Compute the signum function for each number in interval @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sign (infsup (2, 3))
##   @result{} [1]
## sign (infsup (0, 5))
##   @result{} [0, 1]
## sign (infsup (-17))
##   @result{} [-1]
## @end group
## @end example
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = sign (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

l = sign (x.inf);
u = sign (x.sup);

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction
