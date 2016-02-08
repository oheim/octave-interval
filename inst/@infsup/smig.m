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
## @defmethod {@@infsup} smig (@var{X})
## 
## Get the signed mignitude of numbers in interval @var{X}, that is the unique
## number closest to zero for each element.
##
## If @var{X} is empty, @code{smig (@var{X})} is NaN.
##
## Accuracy: The result is exact.
##
## @example
## @group
## smig (infsup (-2, -1))
##   @result{} ans = -1
## @end group
## @end example
## @seealso{@@infsup/mig, @@infsup/mag, @@infsup/inf, @@infsup/sup}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-06-13

function result = smig (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = zeros (size (x.inf));
result (x.inf > 0) = x.inf;
result (x.sup < 0) = x.sup;
result (isempty (x)) = nan ();

endfunction

%!assert (smig (infsup (-1, 2)), 0);
%!assert (smig (infsup (-42, -23)), -23);
%!assert (smig (infsup (23, 42)), 23);
