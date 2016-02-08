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
## @defmethod {@@infsup} psi (@var{X})
## 
## Compute the digamma function, also known as the psi function.
##
## @tex
## $$
##  {\rm psi} (x) = \int_0^\infty \left( {{\exp(-t)} \over t} - {{\exp (-xt)} \over {1 - \exp (-t)}} \right) dt
## $$
## @end tex
## @ifnottex
## @group
## @verbatim
##            ∞
##           /  exp (-t)         exp (-xt)
## psi (x) = | ----------  -  -------------- dt
##           /     t           1 - exp (-t)
##          0
## @end verbatim
## @end group
## @end ifnottex
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## psi (infsup (1))
##   @result{} ans ⊂ [-0.57722, -0.57721]
## @end group
## @end example
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-28

function result = psi (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

u = inf (size (x.inf));
l = -u;

## psi is monotonically increasing, but not defined for non-positive integers.
nosingularity = x.inf >= 0 | ceil (x.inf) > floor (x.sup) | ...
    (ceil (x.inf) == floor (x.sup) & ...
        (fix (x.inf) == x.inf | fix (x.sup) == x.sup));
if (any (any (nosingularity)))
    x.inf (x.inf == 0) = 0; # fix negative zero
    l (nosingularity & (x.inf > 0 | fix (x.inf) ~= x.inf)) = ...
        mpfr_function_d ('psi', -inf, x.inf (nosingularity));
    u (nosingularity & (x.sup > 0 | fix (x.sup) ~= x.sup)) = ...
        mpfr_function_d ('psi', +inf, x.sup (nosingularity));
endif

emptyresult = x.inf == x.sup & fix (x.inf) == x.inf & x.inf <= 0;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!assert (isempty (psi (infsup (0))));
%!assert (isempty (psi (infsup (-1))));
%!assert (isempty (psi (infsup (-2))));
%!assert (isempty (psi (infsup (-3))));
%!assert (isentire (psi (infsup (-inf, -42.23))));
%!assert (isentire (psi (infsup (0, inf))));
%!assert (isentire (psi (infsup (-1, 0))));
%!assert (isentire (psi (infsup (-2, -1))));
%!assert (isentire (psi (infsup (-eps, eps))));
%!assert (isentire (psi (infsup (-1-eps, -1+eps))));
%!assert (isentire (psi (infsup (-4.1, -3.9))));

%!test "from the documentation string";
%! assert (psi (infsup (1)) == "[-0x1.2788CFC6FB619p-1, -0x1.2788CFC6FB618p-1]");
