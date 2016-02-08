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
## @defmethod {@@infsup} erfc (@var{X})
## 
## Compute the complementary error function.
##
## @tex
## $$
##  {\rm erfc} (x) = {2 \over \sqrt{\pi}}\int_x^\infty \exp (-t^2) dt
## $$
## @end tex
## @ifnottex
## @group
## @verbatim
##                   ∞
##              2   /
## erfc (x) = ----- | exp (-t²) dt
##             √π   /
##                 x
## @end verbatim
## @end group
## @end ifnottex
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## erfc (infsup (1))
##   @result{} ans ⊂ [0.15729, 0.1573]
## @end group
## @end example
## @seealso{@@infsup/erf}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-28

function result = erfc (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

## erf is monotonically decreasing
l = mpfr_function_d ('erfc', -inf, x.sup);
u = mpfr_function_d ('erfc', +inf, x.inf);

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (erfc (infsup (1)) == "[0x1.4226162FBDDD4p-3, 0x1.4226162FBDDD5p-3]");
