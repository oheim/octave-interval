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
## @deftypefn {Interval Function} {} @var{X} * @var{Y}
## @cindex IEEE1788 mul
## 
## Multiply all numbers of interval @var{X} by all numbers of @var{Y}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## x * y
##   @result{} [2, 6]
## @end group
## @end example
## @seealso{mrdivide}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-31

function result = mtimes (x, y)

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

if (isscalar (x) || isscalar (y))
    result = times (x, y);
    return
endif

if (size (x.inf, 2) ~= size (y.inf, 1))
    error ("operator *: nonconformant arguments");
endif

l = u = zeros (size (x.inf, 1), size (y.inf, 2));

for i = 1 : rows (l)
    for j = 1 : columns (l)
        element = dot (infsup (x.inf (i, :), x.sup (i, :)), ...
                       infsup (y.inf (:, j), y.sup (:, j)));
        l (i, j) = element.inf;
        u (i, j) = element.sup;
    endfor
endfor

result = infsup (l, u);

endfunction