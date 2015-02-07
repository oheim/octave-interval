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
## @deftypefn {Function File} {} sumsq (@var{X})
## @deftypefnx {Function File} {} sumsq (@var{X}, @var{DIM})
## 
## Sum of squares along dimension @var{DIM}.  If @var{DIM} is omitted,
## it defaults to the first non-singleton dimension.
##
## Accuracy: The result is a nearly tight enclosure (within about 1.5 ULPs of
## the exact result).
##
## @example
## @group
## sumsq ([infsup(1), pow2(-1074), -1])
##   @result{} [2, 2.0000000000000005]
## @end group
## @end example
## @seealso{@@infsup/plus, @@infsup/sum, @@infsup/sumabs, @@infsup/sqr}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function result = sumsq (x, dim)

if (nargin > 2)
    print_usage ();
    return
endif

x = abs (x);
if (nargin < 2)
    result = dot (x, x);
else
    result = dot (x, x, dim);
endif
endfunction