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
## @defmethod {@@infsup} hypot (@var{X}, @var{Y})
## 
## Compute the euclidean norm.
##
## @code{hypot (@var{x}, @var{y}) = sqrt (@var{x}^2 + @var{y}^2)}
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## hypot (x, y)
##   @result{} ans ⊂ [2.236, 3.6056]
## @end group
## @end example
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-20

function result = hypot (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

l = mpfr_function_d ('hypot', -inf, mig (x), mig (y));
u = mpfr_function_d ('hypot', +inf, mag (x), mag (y));

emptyresult = isempty (x) | isempty (y);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (hypot (infsup (2, 3), infsup (1, 2)) == "[0x1.1E3779B97F4A7p1, 0x1.CD82B446159F4p1]");
