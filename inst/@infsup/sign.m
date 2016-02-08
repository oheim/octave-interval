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
## @defmethod {@@infsup} sign (@var{X})
## 
## Compute the signum function for each number in interval @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sign (infsup (2, 3))
##   @result{} ans = [1]
## sign (infsup (0, 5))
##   @result{} ans = [0, 1]
## sign (infsup (-17))
##   @result{} ans = [-1]
## @end group
## @end example
## @end defmethod

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

%!test "from the documentation string";
%! assert (sign (infsup (2, 3)) == infsup (1));
%! assert (sign (infsup (0, 5)) == infsup (0, 1));
%! assert (sign (infsup (-17)) == infsup (-1));
