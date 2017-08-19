## Copyright 2017 Oliver Heimlich
## Copyright 2017 Joel Dahne
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
## Compute the factorial of @var{N} where @var{N} is a non-negative integer.
##
## If @var{N} is a scalar, this is equivalent to
## @display
## factorial (@var{N}) = 1 * 2 * @dots{} * @var{N}.
## @end display
## For vector, matrix or array arguments, return the factorial of each
## element in the array.
##
## For non-integers see the generalized factorial function @command{gamma}.
## Note that the factorial function grows large quite quickly, and the result
## cannot be represented exactly in binary64 for @var{N} ≥ 23 and will overflow
## for @var{N} ≥ 171.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## factorial (infsupdec (6))
##   @result{} ans = [720]_com
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

  result = newdec (factorial (x.infsup));

  ## The function is defined for non-negative integrals only
  defined = issingleton (x) & fix (sup (x)) == sup (x);
  result.dec(not (defined)) = _trv ();

  result.dec = min (result.dec, x.dec);

endfunction

%!# from the documentation string
%!assert (isequal (factorial (infsupdec (6)), infsupdec (720)));

%!assert (isequal (factorial (infsupdec (0)), infsupdec (1)));
%!assert (isequal (factorial (infsupdec ("[0, 1.99]")), infsupdec (1, "trv")));
%!assert (isequal (factorial (infsupdec ("[0, 2]")), infsupdec (1, 2, "trv")));
%!assert (isequal (factorial (infsupdec ("[1.4, 1.6]")), empty ()));
%!assert (isequal (factorial (infsupdec (23)), infsupdec ("[0x1.5e5c335f8a4cdp+74, 0x1.5e5c335f8a4cep+74]_com")));
%!assert (isequal (factorial (infsupdec (171)), infsupdec ("[0x1.fffffffffffffp+1023, Inf]_dac")));
