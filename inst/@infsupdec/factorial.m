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
## factorial (infsupdec (6))
##   @result{} ans = [720]_dac
## @end group
## @end example
## @seealso{@@infsupdec/prod, @@infsupdec/gamma, @@infsupdec/gammaln}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2016-01-31

function result = factorial (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

## The function is not continuous, since it is defined for non-negative
## integrals only.  Thus the best possible decoration can be “dac”.
result = infsupdec (factorial (intervalpart (x)), "dac");
result.dec = min (result.dec, x.dec);

## The function is defined for non-negative integrals only
defined = issingleton (x) & fix (sup (x)) == sup (x);
result.dec (not (defined)) = _trv ();

endfunction

%!test "from the documentation string";
%! assert (factorial (infsupdec (6)) == infsupdec (720, "dac"));
%!assert (factorial (infsupdec (0)) == infsupdec (1, "dac"));
%!assert (factorial (infsupdec ("[0, 1.99]")) == infsupdec (1, "trv"));
%!assert (factorial (infsupdec ("[0, 2]")) == "[1, 2]_trv");
%!assert (factorial (infsupdec ("[1.4, 1.6]")) == "[Empty]_trv");
