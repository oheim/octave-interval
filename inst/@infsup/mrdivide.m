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
## @defop Method {@@infsup} mrdivide (@var{X}, @var{Y})
## @defopx Operator {@@infsup} {@var{X} / @var{Y}}
## 
## Return the interval matrix right division of @var{X} and @var{Y}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## infsup ([1, 2; 3, 4]) / [3, 4; 1, 2]
##   @result{} ans = 2×2 interval matrix
##      [0]   [1]
##      [1]   [0]
## @end group
## @end example
## @seealso{@@infsup/mtimes}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-31

function result = mrdivide (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (isa (y, "infsupdec"))
    if (not (isa (x, "infsupdec")))
        x = infsupdec (x);
    endif
elseif (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (isa (x, "infsupdec"))
    if (not (isa (y, "infsupdec")))
        y = infsupdec (y);
    endif
elseif (not (isa (y, "infsup")))
    y = infsup (y);
endif

if (isscalar (x) || isscalar (y))
    result = rdivide (x, y);
    return
endif

result = mldivide (y', x')';

endfunction

%!test "from the documentation string";
%! assert (infsup ([1, 2; 3, 4]) / [3, 4; 1, 2] == infsup ([0, 1; 1, 0]));
