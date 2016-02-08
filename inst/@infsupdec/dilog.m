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
## @defmethod {@@infsupdec} dilog (@var{X})
## 
## Compute the real part of the dilogarithm function.
##
## @tex
## $$
##  {\rm dilog} (x) = -\Re \int_0^x {{\log (1-t)} \over t} dt
## $$
## @end tex
## @ifnottex
## @group
## @verbatim
##                   x
##                  /  log (1 - t)
## dilog (x) = - Re | ------------- dt
##                  /       t
##                 0
## @end verbatim
## @end group
## @end ifnottex
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## dilog (infsupdec (1))
##   @result{} ans ⊂ [1.6449, 1.645]_com
## @end group
## @end example
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-29

function result = dilog (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (dilog (intervalpart (x)));
## dilog is defined and continuous everywhere
result.dec = min (result.dec, x.dec);

endfunction

%!assert (isequal (dilog (infsupdec (-inf, inf)), infsupdec ("[-Inf, +0x1.3BD3CC9BE45DFp1]_dac")));
%!test "from the documentation string";
%! assert (isequal (dilog (infsupdec (1)), infsupdec ("[0x1.A51A6625307D3, 0x1.A51A6625307D4]_com")));
