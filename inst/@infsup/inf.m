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
## @defmethod {@@infsup} inf (@var{X})
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## 
## Get the (greatest) lower boundary for all numbers of interval @var{X}.
##
## If @var{X} is empty, @code{inf (@var{X})} is positive infinity.
##
## Accuracy: The result is exact.
##
## @example
## @group
## inf (infsup (2.5, 3.5))
##   @result{} ans = 2.5000
## @end group
## @end example
## @seealso{@@infsup/sup, @@infsup/mid}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-27

function result = inf (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = x.inf;

endfunction

%!# from the documentation string
%!assert (inf (infsup (2.5, 3.5)), 2.5);
