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

function result = diag (x, m, n)

if (not (isa (x, 'infsupdec')))
    error ('diag: invalid argument; only the first may be an interval');
endif
if (isnai (x))
    result = x;
    return
endif

switch (nargin)
    case 1
        result = newdec (diag (intervalpart (x)));
        result.dec = diag (x.dec);
    case 2
        result = newdec (diag (intervalpart (x), m));
        result.dec = diag (x.dec, m);
    case 3
        result = newdec (diag (intervalpart (x), m, n));
        result.dec = diag (x.dec, m, n);
    otherwise
        print_usage ();
endswitch

result.dec (result.dec == 0) = _com (); # any new elements are [0]_com

endfunction

%!assert (diag (infsupdec (-inf, inf)) == "[Entire]");
%!assert (diag (infsupdec ()) == "[Empty]");
%!assert (numel (diag (infsupdec ([]))), 0);
%!xtest assert (isequal (diag (infsupdec (magic (3))), infsupdec ([8; 5; 2])));
%!xtest assert (isequal (diag (infsupdec ([8 5 3])), infsupdec ([8 0 0; 0 5 0; 0 0 3])));
