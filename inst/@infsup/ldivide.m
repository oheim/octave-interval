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
## @defop Method {@@infsup} ldivide (@var{X}, @var{Y})
## @defopx Operator {@@infsup} {@var{X} .\ @var{Y}}
## 
## Divide all numbers of interval @var{Y} by all numbers of @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## x .\ y
##   @result{} ans ⊂ [0.33333, 1]
## @end group
## @end example
## @seealso{@@infsup/times}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = ldivide (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif

result = rdivide (y, x);

endfunction

%!test "from the documentation string";
%! assert (ldivide (infsup (2, 3), infsup (1, 2)) == "[1/3, 1]");
