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
## @defmethod {@@infsup} gammaln (@var{X})
## 
## Compute the logarithm of the gamma function for positive arguments.
##
## @tex
## $$
##  {\rm gammaln} (x) = \log \int_0^\infty t^{x-1} \exp (-t) dt
## $$
## @end tex
## @ifnottex
## @group
## @verbatim
##                    ∞
##                   /
## gammaln (x) = log | t^(x-1) exp (-t) dt
##                   /
##                  0
## @end verbatim
## @end group
## @end ifnottex
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## gammaln (infsup (1.5))
##   @result{} ans ⊂ [-0.12079, -0.12078]
## @end group
## @end example
## @seealso{@@infsup/psi, @@infsup/gamma, @@infsup/factorial}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-28

function result = gammaln (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

## The gamma function is also defined for negative, non-integral arguments and
## its logarithm would be defined for −2n <= x <= −2n+1.
## However, we only compute the function for x > 0.

## https://oeis.org/A030169
persistent x_min_inf = 1.4616321449683623;
persistent x_min_sup = 1.4616321449683624;

## Both gammaln (infsup (x_min_inf)) and gammaln (infsup (x_min_sup)) contain
## the exact minimum value of gammaln. Thus we can simply split the function's
## domain in half and assume that each is strictly monotonic.

l = inf (size (x.inf));
u = -l;

## Monotonically decreasing for x1
x1 = intersect (x, infsup (0, x_min_sup));
select = not (isempty (x1)) & x1.sup > 0;
if (any (any (select)))
    x1.inf (x1.inf == 0) = 0; # fix negative zero
    l (select) = mpfr_function_d ('gammaln', -inf, x1.sup (select));
    u (select) = mpfr_function_d ('gammaln', +inf, x1.inf (select));
endif

## Monotonically increasing for x2
x2 = intersect (x, infsup (x_min_inf, inf));
select = not (isempty (x2));
if (any (any (select)))
    l (select) = mpfr_function_d ('gammaln', -inf, x2.inf (select));
    u (select) = max (u (select), ...
                 mpfr_function_d ('gammaln', +inf, x2.sup (select)));
endif

result = infsup (l, u);

endfunction

%!assert (gammaln (infsup (-inf, inf)) == "[-0x1.F19B9BCC38A42p-4, +Inf]");
%!test "from the documentation string";
%! assert (gammaln (infsup (1.5)) == "[-0x1.EEB95B094C192p-4, -0x1.EEB95B094C191p-4]");
