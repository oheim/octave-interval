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
## @defmethod {@@infsup} pow10 (@var{X})
## 
## Compute @code{10^x} for all numbers in @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## pow10 (infsup (5))
##   @result{} ans = [1e+05]
## @end group
## @end example
## @seealso{@@infsup/log10, @@infsup/pow, @@infsup/pow2, @@infsup/exp}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = pow10 (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

## pow10 is monotonically increasing from (-inf, 0) to (inf, inf)
l = mpfr_function_d ('pow10', -inf, x.inf); # this works for empty intervals
u = mpfr_function_d ('pow10', +inf, x.sup); # ... this does not

u (isempty (x)) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (pow10 (infsup (5)) == infsup (100000));
