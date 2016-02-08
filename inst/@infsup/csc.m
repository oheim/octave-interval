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
## @defmethod {@@infsup} csc (@var{X})
## 
## Compute the cosecant in radians, that is the reciprocal sine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## csc (infsup (1))
##   @result{} ans ⊂ [1.1883, 1.1884]
## @end group
## @end example
## @seealso{@@infsup/sin, @@infsup/sec, @@infsup/cot}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function result = csc (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

l = u = derivl = derivu = zeros (size (x.inf));

## Check, if wid (x) is certainly greater than 2*pi. This can save the
## computation if some values.
width = mpfr_function_d ('minus', -inf, x.sup, x.inf);
pi.sup = 0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55);
certainlysingularity = width >= pi.sup;

## We simply compute the cosecant for both endpoints.
x.inf (x.inf == 0) = +0;
x.sup (x.sup == 0) = -0;
select = not (certainlysingularity);
l (select) = min (...
    mpfr_function_d ('csc', -inf, x.inf (select)), ...
    mpfr_function_d ('csc', -inf, x.sup (select)));
u (select) = max (...
    mpfr_function_d ('csc', inf, x.inf (select)), ...
    mpfr_function_d ('csc', inf, x.sup (select)));

## A change of sign is a sufficient singularity indicator
certainlysingularity = certainlysingularity | (select & sign (l) ~= sign (u));
l (certainlysingularity) = -inf;
u (certainlysingularity) = inf;

## Check, whether the interval contains a local extremum using the derivative
select = not (certainlysingularity);
derivl (select) = -mpfr_function_d ('csc', 0, x.inf (select)) .* ...
                   mpfr_function_d ('cot', 0, x.inf (select));
derivu (select) = -mpfr_function_d ('csc', 0, x.sup (select)) .* ...
                   mpfr_function_d ('cot', 0, x.sup (select));
hasextremum = select & ((derivl <= 0 & derivu >= 0) | ...
                        (derivl >= 0 & derivu <= 0));
l (hasextremum & l > 0) = 1;
u (hasextremum & u < 0) = -1;

emptyresult = isempty (x) | (x.inf == 0 & x.sup == 0);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (csc (infsup (1)) == "[0x1.303AA9620B223, 0x1.303AA9620B224]");
