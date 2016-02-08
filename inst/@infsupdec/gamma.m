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
## @defmethod {@@infsupdec} gamma (@var{X})
## 
## Compute the gamma function.
##
## @tex
## $$
##  {\rm gamma} (x) = \int_0^\infty t^(x-1) \exp (-t) dt
## $$
## @end tex
## @ifnottex
## @group
## @verbatim
##              ∞
##             /  
## gamma (x) = | t^(x - 1) * exp (-t) dt
##             /
##            0
## @end verbatim
## @end group
## @end ifnottex
##
## Accuracy: The result is a valid enclosure.  The result is tightest for
## @var{X} >= -10. 
##
## @example
## @group
## gamma (infsupdec (1.5))
##   @result{} ans ⊂ [0.88622, 0.88623]_com
## @end group
## @end example
## @seealso{@@infsupdec/psi, @@infsupdec/gammaln, @@infsupdec/factorial}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-01

function result = gamma (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

if (isnai (x))
    result = x;
    return
endif

result = newdec (gamma (intervalpart (x)));
## gamma is continuous where it is defined
result.dec = min (result.dec, x.dec);

undefined = (inf (x) <= 0 & fix (inf (x)) == inf (x)) | ...
            (sup (x) <= 0 & fix (sup (x)) == sup (x)) | ...
            (inf (x) < 0 & ceil (inf (x)) <= floor (sup (x)));
result.dec (undefined) = min (result.dec (undefined), _trv ());

endfunction

%!test "from the documentation string";
%! assert (isequal (gamma (infsupdec (1.5)), infsupdec ("[0x1.C5BF891B4EF6Ap-1, 0x1.C5BF891B4EF6Bp-1]_com")));
