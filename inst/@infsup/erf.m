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
## @defmethod {@@infsup} erf (@var{X})
## 
## Compute the error function.
##
## @tex
## $$
##  {\rm erf} (x) = {2 \over \sqrt{\pi}}\int_0^x \exp (-t^2) dt
## $$
## @end tex
## @ifnottex
## @group
## @verbatim
##                  x
##             2   /
## erf (x) = ----- | exp (-t²) dt
##            √π   /
##                0
## @end verbatim
## @end group
## @end ifnottex
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## erf (infsup (1))
##   @result{} ans ⊂ [0.8427, 0.84271]
## @end group
## @end example
## @seealso{@@infsup/erfc}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-28

function result = erf (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

## erf is monotonically increasing
l = mpfr_function_d ('erf', -inf, x.inf);
u = mpfr_function_d ('erf', +inf, x.sup);

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (erf (infsup (1)) == "[0x1.AF767A741088Ap-1, 0x1.AF767A741088Bp-1]");
