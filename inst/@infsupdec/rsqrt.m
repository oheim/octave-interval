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
## @defmethod {@@infsupdec} rsqrt (@var{X})
##
## Compute the reciprocal square root (for all positive numbers).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## rsqrt (infsupdec (-6, 4))
##   @result{} ans = [0.5, inf]_trv
## @end group
## @end example
## @seealso{@@infsupdec/realsqrt}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function result = rsqrt (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  result = newdec (rsqrt (x.infsup));

  ## rsqrt is continuous everywhere, but defined for x > 0 only
  persistent domain_hull = infsup (0, inf);
  result.dec(not (interior (x.infsup, domain_hull))) = _trv ();

  result.dec = min (result.dec, x.dec);

endfunction

%!# from the documentation string
%!assert (isequal (rsqrt (infsupdec (-6, 4)), infsupdec (.5, inf, "trv")));
