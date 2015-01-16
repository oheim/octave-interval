## Copyright 2014 Oliver Heimlich
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
## @deftypefn {Function File} {@var{X} =} sinrev (@var{C}, @var{X})
## @deftypefnx {Function File} {@var{X} =} sinrev (@var{C})
## 
## Compute the reverse sine function.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## sinrev (infsup (-1), infsup (0, 6))
##   @result{} [4.7123889803846896, 4.7123889803846906]
## @end group
## @end example
## @seealso{sin}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = sinrev (c, x)

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

arcsine = asin (c);

if (isempty (arcsine) || isempty (x))
    result = infsup ();
    return
endif

pi = infsup ("pi");

if (arcsine.inf <= inf (-pi) / 2 && arcsine.sup >= sup (pi) / 2)
    result = infsup (x.inf, x.sup);
    return
endif

if (x.sup == inf)
    u = inf;
else
    ## Find n, such that x.sup is within a distance of pi/2 around n * pi.
    n = ceil (floor (sup (x.sup / (pi / 2))) / 2);
    if (rem (n, 2) == 0)
        arcsineshifted = arcsine + n * pi;
    else
        arcsineshifted = n * pi - arcsine;
    endif
    if (not (isempty (x & arcsineshifted)))
        u = min (x.sup, arcsineshifted.sup);
    else
        m = mpfr_function_d ('minus', +inf, n, 1);
        if (rem (n, 2) == 0)
            u = sup (m * pi - arcsine);
        else
            u = sup (arcsine + m * pi);
        endif
    endif
endif

if (x.inf == -inf)
    l = -inf;
else
    ## Find n, such that x.inf is within a distance of pi/2 around n * pi.
    n = floor (ceil (inf (x.inf / (pi / 2))) / 2);
    if (rem (n, 2) == 0)
        arcsineshifted = arcsine + n * pi;
    else
        arcsineshifted = n * pi - arcsine;
    endif
    if (not (isempty (x & arcsineshifted)))
        l = max (x.inf, arcsineshifted.inf);
    else
        m = mpfr_function_d ('plus', -inf, n, 1);
        if (rem (n, 2) == 0)
            l = inf (m * pi - arcsine);
        else
            l = inf (arcsine + m * pi);
        endif
    endif
endif

if (l > u)
    result = infsup ();
else
    result = x & infsup (l, u);
endif

endfunction