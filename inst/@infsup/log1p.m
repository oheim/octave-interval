## Copyright 2015 Oliver Heimlich
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
## @deftypefn {Function File} {} log1p (@var{X})
## 
## Compute @code{log (1 + @var{X})} accurately in the neighborhood of zero.
##
## The function is only defined where @var{X} is greater than -1.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## log1p (infsup (eps))
##   @result{} [2.2204460492503128e-16, 2.2204460492503131e-16]
## @end group
## @end example
## @seealso{@@infsup/exp, @@infsup/log}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-20

function result = log1p (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

x = x & infsup (-1, inf);

## log is monotonically increasing from (-1, -inf) to (inf, inf)
l = mpfr_function_d ('log1p', -inf, x.inf); # this works for empty intervals
u = mpfr_function_d ('log1p', +inf, x.sup); # ... this does not

l (x.sup == -1) = inf;
u (isempty (x) | x.sup == -1) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (log1p (infsup (eps)) == "[0x1.FFFFFFFFFFFFFp-53, 0x1p-52]");