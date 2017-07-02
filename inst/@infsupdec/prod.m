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
## @defmethod {@@infsupdec} prod (@var{X})
## @defmethodx {@@infsupdec} prod (@var{X}, @var{DIM})
##
## Product of elements along dimension @var{DIM}.  If @var{DIM} is omitted, it
## defaults to the first non-singleton dimension.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## prod (infsupdec (1 : 4))
##   @result{} ans = [24]_com
## @end group
## @end example
## @seealso{@@infsupdec/sum}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-10-24

function result = prod (x, dim)

  if (nargin > 2)
    print_usage ();
    return
  endif

  if (nargin < 2)
    ## Try to find non-singleton dimension
    dim = find (size (x.dec) ~= 1, 1);
    if (isempty (dim))
      dim = 1;
    endif
  endif

  result = newdec (prod (x.infsup, dim));
  if (not (isempty (x.dec)))
    warning ("off", "Octave:broadcast", "local");
    result.dec = min (result.dec, min (x.dec, [], dim));
  endif

endfunction

%!# from the documentation string
%!assert (prod (infsupdec (1 : 4)) == 24);

%!assert (prod (infsupdec ([])) == 1);

%!assert (isequal (prod (infsupdec (magic (3))), infsupdec ([96, 45, 84])));
%!assert (isequal (prod (infsupdec (magic (3)), 2), infsupdec ([48; 105; 72])));
%!assert (isequal (prod (infsupdec (magic (3)), 3), infsupdec (magic (3))));

%!assert (isequal (prod (prod (reshape (infsup (1:24), 1, 2, 3, 4))), infsup (reshape ([720, 665280, 13366080, 96909120], 1, 1, 1, 4))));
