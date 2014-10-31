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
## @deftypefn {Interval Function} {} sumabs (@var{X})
## @deftypefnx {Interval Function} {} sumabs (@var{X}, @var{DIM})
## @cindex IEEE1788 sumAbs
## 
## Sum of absolute values along dimension @var{DIM}.  If @var{DIM} is omitted,
## it defaults to the first non-singleton dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sumabs ([infsup(1), pow2(-1074), -1])
##   @result{} [2, 2.0000000000000005]
## @end group
## @end example
## @seealso{sum, plus, abs}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function [result, isexact] = sumabs (x, dim)

if (nargin < 2)
    [result, isexact] = sum (abs (x));
else
    [result, isexact] = sum (abs (x), dim);
endif

endfunction