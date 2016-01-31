## Copyright 2016 Oliver Heimlich
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
## @defmethod {@@infsup} factorial (@var{N})
## 
## Compute the factorial of @var{N} where @var{N} is a real non-negative
## integer.
##
## If @var{N} is a scalar, this is equivalent to
## @display
## factorial (@var{N}) = 1 * 2 * @dots{} * @var{N}.
## @end display
## For vector or matrix arguments, return the factorial of each element in the
## array.
##
## For non-integers see the generalized factorial function @command{gamma}.
## Not that the factorial function grows large quite quickly, and the result
## cannot be represented exactly in binary64 for @var{N} ≥ 23 and will overflow
## for @var{N} ≥ 171.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## factorial (infsup (6))
##   @result{} ans = [720]
## @end group
## @end example
## @seealso{@@infsup/prod, @@infsup/gamma, @@infsup/gammaln}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2016-01-31

function result = factorial (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

l = max (0, ceil (x.inf));
u = floor (x.sup);

emptyresult = l > u;
l (emptyresult) = inf;
u (emptyresult) = -inf;

l (not (emptyresult)) = ...
    mpfr_function_d ("factorial", -inf, l (not (emptyresult)));
u (not (emptyresult)) = ...
    mpfr_function_d ("factorial", +inf, u (not (emptyresult)));

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (factorial (infsup (6)) == 720);
%!assert (factorial (infsup (0)) == 1);
%!assert (factorial (infsup ("[0, 1.99]")) == 1);
%!assert (factorial (infsup ("[0, 2]")) == "[1, 2]");
%!assert (factorial (infsup ("[1.4, 1.6]")) == "[Empty]");
