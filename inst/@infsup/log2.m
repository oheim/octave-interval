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
## @defmethod {@@infsup} log2 (@var{X})
## 
## Compute the binary (base-2) logarithm.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## log2 (infsup (2))
##   @result{} ans = [1]
## @end group
## @end example
## @seealso{@@infsup/pow2, @@infsup/log, @@infsup/log10}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = log2 (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

x = intersect (x, infsup (0, inf));

## log2 is monotonically increasing from (0, -inf) to (inf, inf)
l = mpfr_function_d ('log2', -inf, x.inf); # this works for empty intervals
u = mpfr_function_d ('log2', +inf, x.sup); # ... this does not

l (x.sup == 0) = inf;
u (isempty (x) | x.sup == 0) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (log2 (infsup (2)) == 1);
