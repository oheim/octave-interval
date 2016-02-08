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
## @defmethod {@@infsup} mag (@var{X})
## 
## Get the magnitude of numbers in interval @var{X}, that is the maximum of
## absolute values for each element.
##
## If @var{X} is empty, @code{mag (@var{X})} is NaN.
##
## Accuracy: The result is exact.
##
## @example
## @group
## mag (infsup (-3, 2))
##   @result{} ans = 3
## @end group
## @end example
## @seealso{@@infsup/mig, @@infsup/smig, @@infsup/inf, @@infsup/sup}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = mag (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = max (abs (x.inf), abs (x.sup));
result (isempty (x)) = nan ();

endfunction

%!assert (mag (infsup (-3, 4)), 4);
%!assert (mag (infsup (-4, 3)), 4);
