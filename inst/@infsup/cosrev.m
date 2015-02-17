## Copyright 2014-2015 Oliver Heimlich
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
## @deftypefn {Function File} {@var{X} =} cosrev (@var{C}, @var{X})
## @deftypefnx {Function File} {@var{X} =} cosrev (@var{C})
## 
## Compute the reverse cosine function.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{cos (x) ∈ @var{C}}.
## 
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## cosrev (infsup (0), infsup (6,9))
##   @result {} [7.8539816339744827, 7.8539816339744846]
## @end group
## @end example
## @seealso{@@infsup/cos}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = cosrev (c, x)

if (nargin > 2)
    print_usage ();
    return
endif

if (nargin < 2)
    x = infsup (-inf, inf);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

assert (isscalar (c) && isscalar (x), "only implemented for interval scalars");

arccosine = acos (c);

if (isempty (arccosine) || isempty (x))
    result = infsup ();
    return
endif

pi = infsup ("pi");

if (arccosine.inf <= inf (-pi) / 2 && arccosine.sup >= sup (pi) / 2)
    result = infsup (x.inf, x.sup);
    return
endif

if (x.sup == inf)
    u = inf;
else
    ## Find n, such that x.sup is within a distance of pi/2
    ## around (n + 1/2) * pi.
    n = floor (sup (x.sup / pi));
    if (rem (n, 2) == 0)
        arccosineshifted = arccosine + n * pi;
    else
        arccosineshifted = (infsup (n) + 1) * pi - arccosine;
    endif
    if (not (isempty (x & arccosineshifted)))
        u = min (x.sup, arccosineshifted.sup);
    else
        m = mpfr_function_d ('minus', +inf, n, 1);
        if (rem (n, 2) == 0)
            u = sup (n * pi - arccosine);
        else
            u = sup (arccosine + m * pi);
        endif
    endif
endif

if (x.inf == -inf)
    l = -inf;
else
    ## Find n, such that x.inf is within a distance of pi/2
    ## around (n + 1/2) * pi.
    n = floor (inf (x.inf / pi));
    if (rem (n, 2) == 0)
        arccosineshifted = arccosine + n * pi;
    else
        arccosineshifted = (infsup (n) + 1) * pi - arccosine;
    endif
    if (not (isempty (x & arccosineshifted)))
        l = max (x.inf, arccosineshifted.inf);
    else
        m = mpfr_function_d ('plus', -inf, n, 1);
        if (rem (n, 2) == 0)
            l = inf ((infsup (m) + 1) * pi - arccosine);
        else
            l = inf (arccosine + m * pi);
        endif
    endif
endif

if (l > u)
    result = infsup ();
else
    result = x & infsup (l, u);
endif

endfunction
