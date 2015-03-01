## Copyright 2015 Oliver Heimlich
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
## @documentencoding utf-8
## @deftypefn {Function File} {} psi (@var{X})
## 
## Compute the digamma function, also known as the psi function.
##
## @tex
## $$
##  {\rm psi} (x) = \int_0^\infty \left( {{\exp(-t)} \over t} - {{\exp (-xt)} \over {1 - \exp (-t)}} \right) dt
## $$
## @end tex
## @ifnottex
## @example
## @group
##            ∞
##           /  exp (-t)         exp (-xt)
## psi (x) = | ----------  -  -------------- dt
##           /     t           1 - exp (-t)
##          0
## @end group
## @end example
## @end ifnottex
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## psi (infsupdec (1))
##   @result{} [-.5772156649015329, -.5772156649015327]_com
## @end group
## @end example
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-28

function result = psi (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (psi (intervalpart (x)));
## psi is continuous where it is defined
result.dec = mindec (result.dec, x.dec);

undefined = (inf (x) <= 0 & fix (inf (x)) == inf (x)) | ...
            (sup (x) <= 0 & fix (sup (x)) == sup (x)) | ...
            (inf (x) < 0 & ceil (inf (x)) <= floor (sup (x)));
result.dec (undefined) = mindec (result.dec (undefined), "trv");

endfunction

%!assert (isempty (psi (infsupdec (0))));
%!assert (isempty (psi (infsupdec (-1))));
%!assert (isempty (psi (infsupdec (-2))));
%!assert (isempty (psi (infsupdec (-3))));
%!assert (isequal (psi (infsupdec (pow2 (-1074), inf)), infsupdec ("[Entire]_dac")));
%!assert (isequal (psi (infsupdec (0, inf)), infsupdec ("[Entire]_trv")));
%!assert (isequal (psi (infsupdec (-inf, -43.23)), infsupdec ("[Entire]_trv")));
%!assert (isequal (psi (infsupdec (-1, 0)), infsupdec ("[Entire]_trv")));
%!assert (isequal (psi (infsupdec (-2, -1)), infsupdec ("[Entire]_trv")));
%!assert (isequal (psi (infsupdec (-eps, eps)), infsupdec ("[Entire]_trv")));
%!assert (isequal (psi (infsupdec (-1-eps, -1+eps)), infsupdec ("[Entire]_trv")));
%!assert (isequal (psi (infsupdec (-4.1, -3.9)), infsupdec ("[Entire]_trv")));

%!test "from the documentation string";
%! assert (isequal (psi (infsupdec (1)), infsupdec ("[-0x1.2788CFC6FB619p-1, -0x1.2788CFC6FB618p-1]_com")));
