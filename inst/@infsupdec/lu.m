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
## @deftypemethod {@@infsupdec} {[@var{L}, @var{U}] = } lu (@var{A})
## @deftypemethodx {@@infsupdec} {[@var{L}, @var{U}, @var{P}] = } lu (@var{A})
## 
## Compute the LU decomposition of @var{A}.
##
## @var{A} will be a subset of @var{L} * @var{U}.
##
## The result is returned in a permuted form, according to the optional return
## value @var{P}.
##
## Accuracy: The result is a valid enclosure.
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-18

function [L, U, P] = lu (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

P = eye (size (x.dec));
if (isnai (x))
    L = U = x;
    return
endif

if (nargout >= 3)
    [L, U, P] = lu (intervalpart (x));
else
    [L, U] = lu (intervalpart (x));
endif    

## Reverse operations should not carry decoration
L = infsupdec (L, "trv");
U = infsupdec (U, "trv");

endfunction

%!xtest
%! [l, u] = lu (infsupdec (magic (3)));
%! assert (isequal (l, infsupdec ({1, 0, 0; .375, 1, 0; .5, "68/37", 1}, "trv")));, ...
%! assert (subset (u, infsupdec ({8, 1, 6; 0, 4.625, 4.75; 0, 0, "-0x1.3759F2298375Bp3"}, ...
%!                               {8, 1, 6; 0, 4.625, 4.75; 0, 0, "-0x1.3759F22983759p3"})));
%! A = magic (3);
%! A ([1, 5, 9]) = 0;
%! [l, u, p] = lu (infsupdec (A));
%! assert (p, [0, 0, 1; 1, 0, 0; 0, 1, 0]);
%! assert (isequal (l, infsupdec ({1, 0, 0; "4/3", 1, 0; 0, "1/9", 1}, "trv")));
%! assert (subset (u, infsupdec ({3, 0, 7; 0, 9, "-0x1.2AAAAAAAAAAACp3"; 0, 0, "0x1.C25ED097B425Ep2"}, ...
%!                               {3, 0, 7; 0, 9, "-0x1.2AAAAAAAAAAAAp3"; 0, 0, "0x1.C25ED097B426p2"})));
