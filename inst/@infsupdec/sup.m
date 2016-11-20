## Copyright 2016 Oliver Heimlich
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
## @defmethod {@@infsupdec} sup (@var{X})
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## 
## Get the (least) upper boundary for all numbers of interval @var{X}.
##
## If @var{X} is empty, @code{sup (@var{X})} is negative infinity.  If @var{X}
## is NaI, @code{sup (@var{X})} is NaN.
##
## Accuracy: The result is exact.
##
## @example
## @group
## sup (infsupdec (2.5, 3.5))
##   @result{} ans = 3.5000
## @end group
## @end example
## @seealso{@@infsupdec/inf, @@infsup/mid}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2016-09-18

function result = sup (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = sup (x.infsup);
result(isnai (x)) = nan;

endfunction

%!assert (sup (infsupdec (2.5, 3.5)), 3.5);
%!assert (sup (infsupdec ()), -inf);
%!assert (sup (infsupdec ("[nai]")), nan);
%!warning id=interval:UndefinedOperation
%! assert (sup (infsupdec (3, 2)), nan);
