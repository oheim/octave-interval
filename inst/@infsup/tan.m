## Copyright 2014-2016 Oliver Heimlich
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
## @defmethod {@@infsup} tan (@var{X})
## 
## Compute the tangent in radians.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## tan (infsup (1))
##   @result{} ans ⊂ [1.5574, 1.5575]
## @end group
## @end example
## @seealso{@@infsup/atan, @@infsup/tanh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function result = tan (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

l = u = zeros (size (x));

## Check, if wid (x) is certainly greater than pi. This may save computation of
## some tangent values.
width = mpfr_function_d ('minus', -inf, x.sup, x.inf);
pi.sup = 0x6487ED5 * pow2 (-25) + 0x442D190 * pow2 (-55);
certainlyfullperiod = width >= pi.sup;

possiblynotfullperiod = not (certainlyfullperiod);
l (possiblynotfullperiod) = mpfr_function_d ('tan', -inf, x.inf (possiblynotfullperiod));
u (possiblynotfullperiod) = mpfr_function_d ('tan', inf, x.sup (possiblynotfullperiod));

singularity = certainlyfullperiod | ...
              l > u | (...
                  width > 2 & (...
                      sign (l) == sign (u) | ...
                      max (abs (l), abs (u)) < 1));

l (singularity) = -inf;
u (singularity) = inf;

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (tan (infsup (1)) == "[0x1.8EB245CBEE3A5, 0x1.8EB245CBEE3A6]");
