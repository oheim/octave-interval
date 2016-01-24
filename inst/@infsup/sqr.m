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
## @documentencoding UTF-8
## @defmethod {@@infsup} sqr (@var{X})
## 
## Compute the square for each entry in @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sqr (infsup (-2, 1))
##   @result{} ans = [0, 4]
## @end group
## @end example
## @seealso{@@infsup/realsqrt, @@infsup/pown, @@infsup/pow}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = sqr (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

l = mpfr_function_d ('sqr', -inf, mig (x));
u = mpfr_function_d ('sqr', +inf, mag (x));

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (sqr (infsup (-2, 1)) == infsup (0, 4));
