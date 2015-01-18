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
## @deftypefn {Function File} {} fma (@var{X}, @var{Y}, @var{Z})
## 
## Fused multiply and add @code{@var{X} * @var{Y} + @var{Z}}.
##
## This function is semantically equivalent to evaluating multiplication and
## addition separately, but in addition guarantees a tight enclosure of the
## result.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## fma (infsup (1+eps), infsup (7), infsup ("0.1"))
##   @result{} [7.1000000000000014, 7.1000000000000024]
## infsup (1+eps) * infsup (7) + infsup ("0.1")
##   @result{} [7.1000000000000005, 7.1000000000000024]
## @end group
## @end example
## @seealso{@@infsup/plus, @@infsup/times}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-03

function result = fma (x, y, z)

if (nargin ~= 3)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif
if (not (isa (z, "infsup")))
    z = infsup (z);
endif

assert (isscalar (x) && isscalar (y) && isscalar (z), ...
        "only implemented for interval scalars");

if (isempty (x) || isempty (y) || isempty (z))
    result = infsup ();
    return
endif

if ((x.inf == 0 && x.sup == 0) || ...
    (y.inf == 0 && y.sup == 0))
    result = infsup (z.inf, z.sup);
    return
endif

if (isentire (x) || isentire (y) || isentire (z))
    result = infsup (-inf, inf);
    return
endif

if (y.sup <= 0)
    if (x.sup <= 0)
        l = mpfr_function_d ('fma', -inf, x.sup, y.sup, z.inf);
        u = mpfr_function_d ('fma', +inf, x.inf, y.inf, z.sup);
    elseif (x.inf >= 0)
        l = mpfr_function_d ('fma', -inf, x.sup, y.inf, z.inf);
        u = mpfr_function_d ('fma', +inf, x.inf, y.sup, z.sup);
    else
        l = mpfr_function_d ('fma', -inf, x.sup, y.inf, z.inf);
        u = mpfr_function_d ('fma', +inf, x.inf, y.inf, z.sup);
    endif
elseif (y.inf >= 0)
    if (x.sup <= 0)
        l = mpfr_function_d ('fma', -inf, x.inf, y.sup, z.inf);
        u = mpfr_function_d ('fma', +inf, x.sup, y.inf, z.sup);
    elseif (x.inf >= 0)
        l = mpfr_function_d ('fma', -inf, x.inf, y.inf, z.inf);
        u = mpfr_function_d ('fma', +inf, x.sup, y.sup, z.sup);
    else
        l = mpfr_function_d ('fma', -inf, x.inf, y.sup, z.inf);
        u = mpfr_function_d ('fma', +inf, x.sup, y.sup, z.sup);
    endif
else
    if (x.sup <= 0)
        l = mpfr_function_d ('fma', -inf, x.inf, y.sup, z.inf);
        u = mpfr_function_d ('fma', +inf, x.inf, y.inf, z.sup);
    elseif (x.inf >= 0)
        l = mpfr_function_d ('fma', -inf, x.sup, y.inf, z.inf);
        u = mpfr_function_d ('fma', +inf, x.sup, y.sup, z.sup);
    else
        l = min (...
            mpfr_function_d ('fma', -inf, x.inf, y.sup, z.inf), ...
            mpfr_function_d ('fma', -inf, x.sup, y.inf, z.inf));
        u = max (...
            mpfr_function_d ('fma', +inf, x.inf, y.inf, z.sup), ...
            mpfr_function_d ('fma', +inf, x.sup, y.sup, z.sup));
    endif
endif

result = infsup (l, u);

endfunction
