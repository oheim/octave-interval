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
## @defmethod {@@infsup} sumabs (@var{X})
## @defmethodx {@@infsup} sumabs (@var{X}, @var{DIM})
## 
## Sum of absolute values along dimension @var{DIM}.  If @var{DIM} is omitted,
## it defaults to the first non-singleton dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sumabs ([infsup(1), pow2(-1074), -1])
##   @result{} ans ⊂ [2, 2.0001]
## @end group
## @end example
## @seealso{@@infsup/sum, @@infsup/plus, @@infsup/abs}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function result = sumabs (x, dim)

if (nargin > 2)
    print_usage ();
    return
endif

if (nargin < 2)
    result = sum (abs (x));
else
    result = sum (abs (x), dim);
endif

endfunction

%!test "from the documentation string";
%! assert (sumabs ([infsup(1), pow2(-1074), -1]) == infsup (2, 2+eps*2));
%!assert (sumabs (infsup ([])) == 0);