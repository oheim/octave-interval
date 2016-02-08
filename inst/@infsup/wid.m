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
## @defmethod {@@infsup} wid (@var{X})
## 
## Get the width of interval @var{X}.
##
## If @var{X} is empty, @code{wid (@var{X})} is NaN.
## If @var{X} is unbounded in one or both directions, @code{wid (@var{X})} is 
## positive infinity.
##
## Accuracy: The result is a tight enclosure of the interval's actual width.
##
## @example
## @group
## wid (infsup (2.5, 3.5))
##   @result{} ans = 1
## @end group
## @end example
## @seealso{@@infsup/inf, @@infsup/sup, @@infsup/rad}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-05

function result = wid (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = mpfr_function_d ('minus', +inf, x.sup, x.inf);

result (isempty (x)) = nan ();

endfunction

%!test "from the documentation string";
%! assert (wid (infsup (2.5, 3.5)), 1);
