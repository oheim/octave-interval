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
## @defmethod {@@infsup} dilog (@var{X})
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
## dilog (infsup (1))
##   @result{} ans ⊂ [1.6449, 1.645]
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

l = inf (size (x.inf));
u = -l;

## Monotonically increasing for x1
x1 = intersect (x, infsup (-inf, 2));
select = not (isempty (x1));
if (any (any (select)))
    l (select) = mpfr_function_d ('dilog', -inf, x1.inf (select));
    u (select) = mpfr_function_d ('dilog', +inf, x1.sup (select));
endif

## Monotonically decreasing for x2
x2 = intersect (x, infsup (2, inf));
select = not (isempty (x2));
if (any (any (select)))
    l (select) = min (l (select), ...
                 mpfr_function_d ('dilog', -inf, x2.sup (select)));
    u (select) = mpfr_function_d ('dilog', +inf, x2.inf (select));
endif

result = infsup (l, u);

endfunction

%!assert (dilog (infsup (-inf, inf)) == "[-Inf, +0x1.3BD3CC9BE45DFp1]");
%!test "from the documentation string";
%! assert (dilog (infsup (1)) == "[0x1.A51A6625307D3, 0x1.A51A6625307D4]");
