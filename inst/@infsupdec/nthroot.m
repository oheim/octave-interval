## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsupdec} nthroot (@var{X}, @var{N})
##
## Compute the real n-th root of @var{X}.
##
## Accuracy: The result is a valid enclosure.  The result is a tight
## enclosure for @var{n} ≥ -2.  The result also is a tight enclosure if the
## reciprocal of @var{n} can be computed exactly in double-precision.
## @seealso{@@infsupdec/pown, @@infsupdec/pownrev, @@infsupdec/realsqrt, @@infsupdec/cbrt}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-20

function result = nthroot (x, n)

  if (nargin ~= 2)
    print_usage ();
    return
  endif
  if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
  endif

  result = newdec (nthroot (intervalpart (x), n));

  ## nthroot is continuous everywhere, but not defined everywhere
  even = mod (n, 2) == 0;
  defined = (not (even) & (n > 0 | inf (x) > 0 | sup (x) < 0)) ...
            | (even & ((n > 0 & inf (x) >= 0)| (n < 0 & inf (x) > 0)));
  result.dec(not (defined)) = _trv ();

  result.dec = min (result.dec, x.dec);

endfunction

%!assert (isequal (nthroot (infsupdec (25, 36), 2), infsupdec (5, 6)));

%!assert (isequal (nthroot (infsupdec (-1, 1), 2), infsupdec (0, 1, "trv")));
%!assert (isequal (nthroot (infsupdec (-1, 1), 3), infsupdec (-1, 1)));
%!assert (isequal (nthroot (infsupdec (-1, 1), -2), infsupdec (1, inf, "trv")));
%!assert (isequal (nthroot (infsupdec (-1, 1), -3), infsupdec (-inf, inf, "trv")));
