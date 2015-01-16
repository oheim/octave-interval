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
## @deftypefn {Function File} {} {} @var{X} * @var{Y}
## @deftypefnx {Function File} {} mtimes (@var{X}, @var{Y})
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

if (nargin < 2)
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

## Initialize result matrix
result = infsup (inf (size (x.inf, 1), size (y.inf, 2)), ...
                -inf (size (x.inf, 1), size (y.inf, 2)));

## Minimize the number of dot calls: Compute the result row-wise or column-wise
idx.type = "()";
idx.subs = {":", ":"};
if (size (x.inf, 1) >= size (y.inf, 2))
    for i = 1 : size (x.inf, 1)
        idx.subs {1} = i;
        result = subsasgn (result, idx, ...
                           dot (subsref (x, idx)', y, 1));
    endfor
else
    for j = 1 : size (y.inf, 2)
        idx.subs {2} = j;
        result = subsasgn (result, idx, ...
                           dot (x, subsref (y, idx)', 2));
    endfor
endif

endfunction