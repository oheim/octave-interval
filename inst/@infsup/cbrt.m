## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsup} cbrt (@var{X})
##
## Compute the cube root.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## cbrt (infsup (-27, 27))
##   @result{} ans = [-3, +3]
## @end group
## @end example
## @seealso{@@infsup/realsqrt, @@infsup/nthroot}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function x = cbrt (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  x.inf = mpfr_function_d ('cbrt', -inf, x.inf);
  x.sup = mpfr_function_d ('cbrt', +inf, x.sup);

endfunction

%!# from the documentation string
%!assert (cbrt (infsup (-27, 27)) == infsup (-3, 3));

%!# correct use of signed zeros
%!test
%! x = cbrt (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));
