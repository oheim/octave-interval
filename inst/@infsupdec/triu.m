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
## @defmethod {@@infsup} triu (@var{A})
## @defmethodx {@@infsup} triu (@var{A}, @var{k})
## @defmethodx {@@infsup} triu (@var{A}, @var{k}, "pack")
## Return a new matrix formed by extracting the upper triangular part of the
## matrix @var{A}, and setting all other elements to zero.
##
## The second argument is optional, and specifies how many diagonals above or
## below the main diagonal should also be set to zero.
##
## If the option @option{pack} is given as third argument, the extracted
## elements are not inserted into a matrix, but rather stacked column-wise one
## above other.
##
## @seealso{@@infsupdec/tril, @@infsupdec/diag}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2016-08-04

function A = triu (A, varargin)

  if (nargin > 3)
    print_usage ();
    return
  endif

  if (nargin >= 2 && isa (varargin{1}, 'infsup'))
    error ('triu: invalid second argument; it must not be an interval');
  endif
  if (nargin >= 3 && isa (varargin{2}, 'infsup'))
    error ('triu: invalid third argument; it must not be an interval');
  endif

  A.infsup = triu (A.infsup, varargin{:});

  A.dec(A.dec == 0) = uint8 (255);
  A.dec = triu (A.dec, varargin{:});
  A.dec(A.dec == 0) = _com (); # any new elements are [0]_com
  A.dec(A.dec == uint8 (255)) = uint8 (0);

endfunction

%!assert (triu (infsupdec (magic (10))) == triu (magic (10)));
%!assert (triu (infsupdec (magic (10)), 1) == triu (magic (10), 1));
%!assert (triu (infsupdec (magic (10)), -1) == triu (magic (10), -1));
%!assert (triu (infsupdec (magic (10)), 0, "pack") == triu (magic (10), 0, "pack"));
%!test
%! A = infsupdec (zeros (3), "trv");
%! assert (decorationpart (triu (A)), {"trv", "trv", "trv"; "com", "trv", "trv"; "com", "com", "trv"});
