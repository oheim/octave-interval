## Copyright 2015 Oliver Heimlich
## Copyright 2018 Joel Dahne
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
## @defmethod {@@infsupdec} mince (@var{X})
## @defmethodx {@@infsupdec} mince (@var{X}, @var{N})
##
## Mince interval @var{X} into a row vector of @var{N} sub-intervals of equal
## size.
##
## The sub-intervals are returned in ascending order and may overlap due to
## round-off errors.
##
## If @var{X} is a vector it is converted to a column vector and the
## result is a matrix where the rows are independent sequences.  The
## default value for @var{N} is 100.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## mince (infsupdec (0, 10), 4)
##   @result{} ans = 1×4 interval vector
##
##        [0, 2.5]_trv   [2.5, 5]_trv   [5, 7.5]_trv   [7.5, 10]_trv
## @end group
## @end example
## @seealso{@@infsupdec/linspace, @@infsupdec/bisect}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-07-19

function result = mince (x, n)

  if (nargin > 2)
    print_usage ();
    return
  endif
  if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
  endif
  if (nargin < 2)
    n = 100;
  endif

  if (not (isvector (x)))
    error ("linspace: x must be a scalar or a vector");
  endif

  ## Convert x to a column vector
  x = reshape (x, [], 1);

  result = infsupdec (mince (x.infsup, n), "trv");
  result.dec = min (result.dec, x.dec);

endfunction

%!assert (isequal (mince (infsupdec (0, 10), 10), infsupdec (0 : 9, 1 : 10, "trv")));

%!assert (size (mince (infsupdec (zeros (1, 0), ones (1, 0)), 2)), [0 2]);
