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
## @defmethod {@@infsup} gamma (@var{X})
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
## gamma (infsup (1.5))
##   @result{} ans ⊂ [0.88622, 0.88623]
## @end group
## @end example
## @seealso{@@infsup/psi, @@infsup/gammaln, @@infsup/factorial}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-01

function result = gamma (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

u = inf (size (x.inf));
l = -u;

## Positive x =================================================================

## https://oeis.org/A030169
persistent x_min_inf = 1.4616321449683623;
persistent x_min_sup = 1.4616321449683624;

## Both gamma (infsup (x_min_inf)) and gamma (infsup (x_min_sup)) contain
## the exact minimum value of gamma. Thus we can simply split the function's
## domain in half and assume that each is strictly monotonic.

l = inf (size (x.inf));
u = -l;

## Monotonically decreasing for x1
x1 = intersect (x, infsup (0, x_min_sup));
select = not (isempty (x1)) & x1.sup > 0;
if (any (any (select)))
    x1.inf (x1.inf == 0) = 0; # fix negative zero
    l (select) = mpfr_function_d ('gamma', -inf, x1.sup (select));
    u (select) = mpfr_function_d ('gamma', +inf, x1.inf (select));
endif

## Monotonically increasing for x2
x2 = intersect (x, infsup (x_min_inf, inf));
select = not (isempty (x2));
if (any (any (select)))
    l (select) = mpfr_function_d ('gamma', -inf, x2.inf (select));
    u (select) = max (u (select), ...
                 mpfr_function_d ('gamma', +inf, x2.sup (select)));
endif

pos = infsup (l, u);

## Negative x =================================================================

x = intersect (x, infsup (-inf, 0));

u = inf (size (x.inf));
l = -u;

nosingularity = floor (x.inf) + 1 == ceil (x.sup);
if (any (any (nosingularity)))
    negative_value = nosingularity & mod (ceil (x.sup), 2) == 0;
    positive_value = nosingularity & not (negative_value);
    
    x.sup (x.sup == 0) = -0; # fix negative zero
    
    psil = psiu = zeros (size (x.inf));
    psil (nosingularity) = mpfr_function_d ('psi', 0, x.inf (nosingularity));
    psil (isnan (psil)) = -inf;
    psiu (nosingularity) = mpfr_function_d ('psi', 0, x.sup (nosingularity));
    psiu (isnan (psiu)) = inf;
    
    encloses_extremum = false (size (x.inf));
    encloses_extremum (nosingularity) = ...
        psil (nosingularity) <= 0 & psiu (nosingularity) >= 0;
    encloses_extremum (x.sup == x.inf + 1) = true ();
    
    select = encloses_extremum & negative_value & ...
             fix (x.inf) ~= x.inf & fix (x.sup) ~= x.sup;
    if (any (any (select)))
        l (select) = min (mpfr_function_d ('gamma', -inf, x.inf (select)), ...
                          mpfr_function_d ('gamma', -inf, x.sup (select)));
    endif
    select = encloses_extremum & positive_value & ...
             fix (x.inf) ~= x.inf & fix (x.sup) ~= x.sup;
    if (any (any (select)))         
        u (select) = max (mpfr_function_d ('gamma', +inf, x.inf (select)), ...
                          mpfr_function_d ('gamma', +inf, x.sup (select)));
    endif

    select = not (encloses_extremum) & negative_value;
    u (select) = -inf;
    select = not (encloses_extremum) & positive_value;
    l (select) = inf;
    
    select = nosingularity & not (encloses_extremum);
    if (any (any (select)))
        l (select) = min (l (select), ...
                     min (mpfr_function_d ('gamma', -inf, x.inf (select)), ...
                          mpfr_function_d ('gamma', -inf, x.sup (select))));
        u (select) = max (u (select), ...
                     max (mpfr_function_d ('gamma', +inf, x.inf (select)), ...
                          mpfr_function_d ('gamma', +inf, x.sup (select))));
    endif
    
    select = encloses_extremum & negative_value;
    if (any (any (select)))
        u (select) = find_extremum (x.inf (select), x.sup (select));
    endif
    select = encloses_extremum & positive_value;
    if (any (any (select)))
        l (select) = find_extremum (x.inf (select), x.sup (select));
    endif
endif

emptyresult = (x.inf == x.sup & fix (x.inf) == x.inf & x.inf <= 0) | x.inf > 0;
l (emptyresult) = inf;
u (emptyresult) = -inf;

neg = infsup (l, u);

## ============================================================================

result = union (pos, neg);

endfunction

function y = find_extremum (l, u)
## Compute the extremum's value of gamma between l and u.  l and u are negative
## and lie between two subsequent integral numbers.

y = zeros (size (l)); # inaccurate, but already correct

## Tightest values for l >= -10
n = floor (l);
y (n == -1) = -3.544643611155005;
y (n == -2) = 2.3024072583396799;
y (n == -3) = -.8881363584012418;
y (n == -4) = .24512753983436624;
y (n == -5) = -.052779639587319397;
y (n == -6) = .009324594482614849;
y (n == -7) = -.001397396608949767;
y (n == -8) = 1.8187844490940416e-4;
y (n == -9) = -2.0925290446526666e-5;
y (n == -10) = 2.1574161045228504e-6;

## From Euler's reflection formula it follows:
## gamma (-x) = pi / ( sin (pi * (x + 1)) * gamma (x + 1) )
##
## The extremum is located at -x = n + epsilon,
## where epsilon < 0.3 for n <= -10. Thus, we can estimate
## abs (pi / sin (pi * (x + 1))) >= 3.88 for n <= -10.
## Also it holds gamma (x + 1) = gamma (-n - epsilon + 1) <= gamma  (-n + 1).
##
## Now, altogether we can estimate: abs (gamma (-x)) >= 3.88 / gamma (-n + 1)
## for n <= -10

remaining_estimates = n < -10;
if (any (any (remaining_estimates)))
    y (remaining_estimates) = ...
        (-1) .^ (rem (n (remaining_estimates), 2) == -1) * ...
        mpfr_function_d ('rdivide', -inf, 3.88, ...
            mpfr_function_d ('gamma', +inf, -n (remaining_estimates) + 1));
endif

endfunction

%!test "from the documentation string";
%! assert (gamma (infsup (1.5)) == "[0x1.C5BF891B4EF6Ap-1, 0x1.C5BF891B4EF6Bp-1]");
