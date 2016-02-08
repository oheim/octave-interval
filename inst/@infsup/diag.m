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
## @deftypemethod {@@infsup} {M =} diag (@var{V})
## @deftypemethodx {@@infsup} {V =} diag (@var{M})
## @deftypemethodx {@@infsup} {M =} diag (@var{V}, @var{K})
## @deftypemethodx {@@infsup} {M =} diag (@var{V}, @var{M}, @var{N})
## @deftypemethodx {@@infsup} {V =} diag (@var{M}, @var{K})
## 
## Create a diagonal matrix @var{M} with vector @var{V} on diagonal @var{K} or
## extract a vector @var{V} from the @var{K}-th diagonal of matrix @var{M}.
##
## With three arguments, create a matrix of size @var{M}×@var{N}.
##
## @example
## @group
## diag (infsup (1 : 3))
##   @result{} ans = 3×3 interval matrix
##     
##        [1]   [0]   [0]
##        [0]   [2]   [0]
##        [0]   [0]   [3]
## @end group
## @end example
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-10-23

function result = diag (x, m, n)

if (nargin >= 2 && isa (m, 'infsup'))
    error ('diag: invalid second argument; it must not be an interval');
endif
if (nargin >= 3 && isa (n, 'infsup'))
    error ('diag: invalid third argument; it must not be an interval');
endif

switch (nargin)
    case 1
        result = infsup (diag (x.inf), diag (x.sup));
    case 2
        result = infsup (diag (x.inf, m), diag (x.sup, m));
    case 3
        result = infsup (diag (x.inf, m, n), diag (x.sup, m, n));
    otherwise
        print_usage ();
endswitch

endfunction

%!assert (diag (infsup (-inf, inf)) == "[Entire]");
%!assert (diag (infsup ()) == "[Empty]");
%!assert (numel (diag (infsup ([]))), 0);
%!xtest assert (isequal (diag (infsup (magic (3))), infsup ([8; 5; 2])));
%!xtest assert (isequal (diag (infsup ([8 5 3])), infsup ([8 0 0; 0 5 0; 0 0 3])));
