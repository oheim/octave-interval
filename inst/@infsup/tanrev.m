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
## @deftypefn {Function File} {@var{X} =} tanrev (@var{C}, @var{X})
## @deftypefnx {Function File} {@var{X} =} tanrev (@var{C})
## 
## Compute the reverse tangent function.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## tanrev (infsup (0), infsup (2, 4))
##   @result{} [3.1415926535897931, 3.1415926535897936]
## @end group
## @end example
## @seealso{@@infsup/tan}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = tanrev (c, x)

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

if (isempty (c) || isempty (x))
    result = infsup ();
    return
endif

arctangent = atan (c);

if (isentire (arctangent))
    result = infsup (x.inf, x.sup);
    return
endif

pi = infsup ("pi");

if (x.sup == inf)
    u = inf;
else
    ## Find n, such that x.sup is within a distance of pi/2 around n * pi.
    n = ceil (floor (sup (x.sup / (pi / 2))) / 2);
    arctangentshifted = arctangent + n * pi;
    if (not (isempty (x & arctangentshifted)))
        u = min (x.sup, arctangentshifted.sup);
    else
        m = mpfr_function_d ('minus', +inf, n, 1);
        u = sup (arctangent + m * pi);
    endif
endif

if (x.inf == -inf)
    l = -inf;
else
    ## Find n, such that x.inf is within a distance of pi/2 around n * pi.
    n = floor (ceil (inf (x.inf / (pi / 2))) / 2);
    arctangentshifted = arctangent + n * pi;
    if (not (isempty (x & arctangentshifted)))
        l = max (x.inf, arctangentshifted.inf);
    else
        m = mpfr_function_d ('plus', -inf, n, 1);
        l = inf (arctangent + m * pi);
    endif
endif

if (l > u)
    result = infsup ();
else
    result = x & infsup (l, u);
endif

endfunction
