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

## @deftypefn {Interval Numeric} {} length (@var{A})
##
## Return the length of interval object @var{A}.
##
## The length is 0 for empty objects, 1 for scalars, and the number of elements
## for vectors.  For matrix objects, the length is the number of rows or
## columns, whichever is greater.
## @seealso{numel, size, rows, columns}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

function result = length (a)

result = length (a.inf);

endfunction