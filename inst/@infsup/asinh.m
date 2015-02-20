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
## @deftypefn {Function File} {} asinh (@var{X})
## 
## Compute the inverse hyperbolic sine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## asinh (infsup (1))
##   @result{} [.8813735870195429, .8813735870195431]
## @end group
## @end example
## @seealso{@@infsup/sinh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = asinh (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

## asinh is monotonically increasing
## This also works for empty intervals!
l = mpfr_function_d ('asinh', -inf, x.inf);
u = mpfr_function_d ('asinh', +inf, x.sup);

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (asinh (infsup (1)) == "[0x1.C34366179D426p-1, 0x1.C34366179D427p-1]");
