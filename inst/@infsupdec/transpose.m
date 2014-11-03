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

## @deftypefn {Interval Function} {} @var{X} .'
##
## Return the transpose of interval matrix or vector @var{X}.
##
## @example
## @group
## infsupdec (zeros (1, 3), ones (1, 3)) .'
##   @result{} 3×1 interval vector
##
##      [0, 1]_com
##      [0, 1]_com
##      [0, 1]_com
## @end group
## @end example
## @seealso{ctranspose}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-11-02

function result = transpose (x)

result = infsupdec (transpose (intervalpart (x)), transpose (x.dec));

endfunction