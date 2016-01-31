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
## @defop Method {@@infsup} mpower (@var{X}, @var{Y})
## @defopx Operator {@@infsup} {@var{X} ^ @var{Y}}
## 
## Return the matrix power operation of @var{X} raised to the @var{Y} power.
##
## If @var{X} is a scalar, this function and @code{power} are equivalent.
## Otherwise, @var{X} must be a square matrix and @var{Y} must be a single
## integer.
##
## Warning: This function is not defined by IEEE Std 1788-2015.
##
## Accuracy: The result is a valid enclosure.  The result is tightest for
## @var{Y} in @{0, 1, 2@}.
##
## @example
## @group
## infsupdec (magic (3)) ^ 2
##   @result{} ans = 3×3 interval matrix
##      [91]_com   [67]_com   [67]_com
##      [67]_com   [91]_com   [67]_com
##      [67]_com   [67]_com   [91]_com
## @end group
## @end example
## @seealso{@@infsupdec/pow, @@infsupdec/pown, @@infsupdec/pow2, @@infsupdec/pow10, @@infsupdec/exp}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2016-01-24

function result = mpower (x, y)

if (nargin != 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

if (isscalar (x.dec))
    ## Short-circuit for scalars
    result = power (x, y);
    return
endif

if (not (isreal (y)) || fix (y) ~= y)
    error ("interval:InvalidOperand", ...
           "mpower: only integral powers can be computed");
endif

result = newdec (mpower (intervalpart (x), y));

if (y < 0)
    result.dec(:) = _trv ();
elseif (y < 2)
    result.dec = x.dec;
elseif (y == 2)
    warning ('off', 'Octave:broadcast', 'local');
    result.dec = min (result.dec, min (min (x.dec, [], 1), ...
                                       min (x.dec, [], 2)));
elseif (y > 2)
    result.dec = min (result.dec, min (min (x.dec)));
endif

endfunction

%!xtest "from the documentation string";
%! assert (isequal (infsupdec (magic (3)) ^ 2, infsupdec (magic (3) ^ 2)));
