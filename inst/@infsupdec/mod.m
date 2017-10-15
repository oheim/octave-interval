## Copyright 2017 Oliver Heimlich
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
## @defmethod {@@infsupdec} mod (@var{X}, @var{Y})
##
## Compute the modulus of @var{X} and @var{Y}.
##
## Conceptionally, it is given by the expression
## @code{@var{X} - @var{Y} .* floor (@var{X} ./ @var{Y})}.  This function is
## undefined for @var{Y} = 0.
##
## @example
## @group
## mod (infsupdec (3), infsupdec (2))
##   @result{} ans = [1]_com
## mod (infsupdec (-3), infsupdec (2))
##   @result{} ans = [1]_com
## @end group
## @end example
##
## Accuracy: The result is a valid enclosure.
##
## @seealso{@@infsupdec/rdivide, @@infsupdec/rem}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2017-10-15

function result = mod (x, y)

  if (nargin ~= 2)
    print_usage ();
    return
  endif

  ## Usually, the implementation of an interval arithmetic function is cleanly
  ## split into a bare and a decorated version.  This function's decoration is
  ## quite complicated to be computed and depends on intermediate values that
  ## are used to compute the bare interval result.  Thus, we get most of the
  ## decoration information as a second output parameter from @infsup.

  if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
  endif
  if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
  endif

  [bare, d] = mod (x.infsup, y.infsup);
  result = newdec (bare);

  result.dec = min (result.dec, min (d, min (x.dec, y.dec)));

endfunction

%!assert (isequal (mod (infsupdec (), infsupdec ()), infsupdec ()));
%!assert (isequal (mod (infsupdec (0), infsupdec ()), infsupdec ()));
%!assert (isequal (mod (infsupdec (), infsupdec (0)), infsupdec ()));

%!assert (isequal (mod (infsupdec (0), infsupdec (0)), infsupdec ()));
%!assert (isequal (mod (infsupdec (1), infsupdec (0)), infsupdec ()));
%!assert (isequal (mod (infsupdec (0, 1), infsupdec (0)), infsupdec ()));
%!assert (isequal (mod (infsupdec (1, 2), infsupdec (0)), infsupdec ()));
%!assert (isequal (mod (infsupdec (0, inf), infsupdec (0)), infsupdec ()));
%!assert (isequal (mod (infsupdec (1, inf), infsupdec (0)), infsupdec ()));
%!assert (isequal (mod (infsupdec (realmax, inf), infsupdec (0)), infsupdec ()));

%!assert (isequal (mod (infsupdec (0), infsupdec (1)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (0), infsupdec (0, 1)), infsupdec (0, "trv")));
%!assert (isequal (mod (infsupdec (0), infsupdec (1, 2)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (0), infsupdec (0, inf)), infsupdec (0, "trv")));
%!assert (isequal (mod (infsupdec (0), infsupdec (1, inf)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (0), infsupdec (realmax, inf)), infsupdec (0, "dac")));

%!assert (isequal (mod (infsupdec (1), infsupdec (1)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (2), infsupdec (1)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (4), infsupdec (2)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (6), infsupdec (3)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (8), infsupdec (2)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (9), infsupdec (3)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (realmax), infsupdec (realmax)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (realmax), infsupdec (realmax / 2)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (realmax), infsupdec (realmax / 4)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (realmax), infsupdec (realmax / 8)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (realmax), infsupdec (realmax / 16)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (realmax), infsupdec (realmax / 32)), infsupdec (0, "dac")));

%!assert (isequal (mod (infsupdec (0.1), infsupdec (0.1)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (0.1 * 2), infsupdec (0.1)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (0.1 * 4), infsupdec (0.1)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (pi), infsupdec (pi)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (pi), infsupdec (pi / 2)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (pi), infsupdec (pi / 4)), infsupdec (0, "dac")));

%!assert (isequal (mod (infsupdec (pow2 (-1074)), infsupdec (pow2 (-1074))), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (pow2 (-1073)), infsupdec (pow2 (-1074))), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (pow2 (-1072)), infsupdec (pow2 (-1074))), infsupdec (0, "dac")));

%!assert (isequal (mod (infsupdec (1), infsupdec (2)), infsupdec (1)));
%!assert (isequal (mod (infsupdec (0.5), infsupdec (1)), infsupdec (0.5)));
%!assert (isequal (mod (infsupdec (pi), infsupdec (3.15)), infsupdec (pi)));

%!assert (isequal (mod (infsupdec (1), infsupdec (2, 3)), infsupdec (1)));
%!assert (isequal (mod (infsupdec (1), infsupdec (2, inf)), infsupdec (1, "dac")));
%!assert (isequal (mod (infsupdec (0.5), infsupdec (1, 2)), infsupdec (0.5)));
%!assert (isequal (mod (infsupdec (0.5), infsupdec (1, inf)), infsupdec (0.5, "dac")));
%!assert (isequal (mod (infsupdec (pi), infsupdec (3.15)), infsupdec (pi)));
%!assert (isequal (mod (infsupdec (pi), infsupdec (3.15, inf)), infsupdec (pi, "dac")));

%!assert (isequal (mod (infsupdec (0, 1), infsupdec (0, 1)), infsupdec (0, 1, "trv")));
%!assert (isequal (mod (infsupdec (0, 2), infsupdec (0, 1)), infsupdec (0, 1, "trv")));
%!assert (isequal (mod (infsupdec (0, 1), infsupdec (0, 2)), infsupdec (0, 1, "trv")));
%!assert (isequal (mod (infsupdec (0, realmax), infsupdec (0, realmax)), infsupdec (0, realmax, "trv")));
%!assert (isequal (mod (infsupdec (realmax, inf), infsupdec (realmax, inf)), infsupdec (0, inf, "def")));
%!assert (isequal (mod (infsupdec (0, inf), infsupdec (0, inf)), infsupdec (0, inf, "trv")));

%!assert (isequal (mod (infsupdec (0), infsupdec (1)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (1), infsupdec (1)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (0, 1), infsupdec (1)), infsupdec (0, 1, "def")));
%!assert (isequal (mod (infsupdec (1, 2), infsupdec (1)), infsupdec (0, 1, "def")));
%!assert (isequal (mod (infsupdec (0, inf), infsupdec (1)), infsupdec (0, 1, "def")));
%!assert (isequal (mod (infsupdec (1, inf), infsupdec (1)), infsupdec (0, 1, "def")));
%!assert (isequal (mod (infsupdec (realmax, inf), infsupdec (1)), infsupdec (0, 1, "def")));

%!assert (isequal (mod (infsupdec (1), infsupdec (1)), infsupdec (0, "dac")));
%!assert (isequal (mod (infsupdec (1), infsupdec (0, 1)), infsupdec (0, 0.5, "trv")));
%!assert (isequal (mod (infsupdec (1), infsupdec (1, 2)), infsupdec (0, 1, "def")));
%!assert (isequal (mod (infsupdec (1), infsupdec (0, inf)), infsupdec (0, 1, "trv")));
%!assert (isequal (mod (infsupdec (1), infsupdec (1, inf)), infsupdec (0, 1, "def")));
%!assert (isequal (mod (infsupdec (1), infsupdec (2, inf)), infsupdec (1, "dac")));
%!assert (isequal (mod (infsupdec (1), infsupdec (realmax, inf)), infsupdec (1, "dac")));
