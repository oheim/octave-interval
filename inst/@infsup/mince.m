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
## @defmethod {@@infsup} mince (@var{X})
## @defmethodx {@@infsup} mince (@var{X}, @var{N})
## 
## Mince interval @var{X} into a row vector of @var{N} sub-intervals of equal
## size.
##
## The sub-intervals are returned in ascending order and may overlap due to
## round-off errors.
##
## If @var{X} is not a scalar, the result is a matrix.  The default value for
## @var{N} is 100.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## mince (infsup (0, 10), 4)
##   @result{} ans = 1×4 interval vector
##
##        [0, 2.5]   [2.5, 5]   [5, 7.5]   [7.5, 10]
## @end group
## @end example
## @seealso{@@infsup/linspace, @@infsup/bisect}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-07-19

function result = mince (x, n)

if (nargin > 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (nargin < 2)
    n = 100;
endif

base = limit = x;
idx.type = '()';
idx.subs = {isfinite(x.inf)};
base = subsasgn (base, idx, infsup (subsref (x.inf, idx)));
idx.subs = {isfinite(x.sup)};
limit = subsasgn (limit, idx, infsup (subsref (x.sup, idx)));

boundaries = linspace (base, limit, n + 1);
l = boundaries.inf (:, 1 : end - 1);
u = boundaries.sup (:, 2 : end);

empty = vec (isempty (x));
l(empty, :) = inf;
u(empty, :) = -inf;

result = infsup (l, u);

endfunction

%!xtest assert (isequal (mince (infsup (0, 10), 10), infsup (0 : 9, 1 : 10)));
