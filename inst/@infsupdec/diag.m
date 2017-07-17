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
## @deftypemethod {@@infsupdec} {M =} diag (@var{V})
## @deftypemethodx {@@infsupdec} {V =} diag (@var{M})
## @deftypemethodx {@@infsupdec} {M =} diag (@var{V}, @var{K})
## @deftypemethodx {@@infsupdec} {M =} diag (@var{V}, @var{M}, @var{N})
## @deftypemethodx {@@infsupdec} {V =} diag (@var{M}, @var{K})
##
## Create a diagonal matrix @var{M} with vector @var{V} on diagonal @var{K} or
## extract a vector @var{V} from the @var{K}-th diagonal of matrix @var{M}.
##
## With three arguments, create a matrix of size @var{M}×@var{N}.
##
## @example
## @group
## diag (infsupdec (1 : 3))
##   @result{} ans = 3×3 interval matrix
##
##        [1]_com   [0]_com   [0]_com
##        [0]_com   [2]_com   [0]_com
##        [0]_com   [0]_com   [3]_com
## @end group
## @end example
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-10-24

function x = diag (x, varargin)

  if (nargin > 3)
    print_usage ();
    return
  endif

  if ((nargin >= 2 && isa (varargin{1}, 'infsup')) || ...
      (nargin >= 3 && isa (varargin{2}, 'infsup')))
    error ('diag: invalid argument; only the first may be an interval');
  endif

  x.dec(x.dec == 0) = uint8 (255);

  x.infsup = diag (x.infsup, varargin{:});
  x.dec = diag (x.dec, varargin{:});

  x.dec(x.dec == uint8 (0)) = _com (); # any new elements are [0]_com
  x.dec(x.dec == uint8 (255)) = uint8 (0);

endfunction

%!assert (diag (infsupdec (-inf, inf)) == "[Entire]");
%!assert (diag (infsupdec ()) == "[Empty]");
%!assert (numel (diag (infsupdec ([]))), 0);
%!assert (isequal (diag (infsupdec (magic (3))), infsupdec ([8; 5; 2])));
%!assert (isequal (diag (infsupdec ([8 5 3])), infsupdec ([8 0 0; 0 5 0; 0 0 3])));
