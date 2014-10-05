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

## usage: a ~= b
## usage: a != b
##
## Implement the not equal to operator on intervals for convenience.
##
## See also:
##  equal

## Author: Oliver Heimlich
## Keywords: interval comparison operator
## Created: 2014-09-30

function result = ne(a, b)

result = not (eq (a, b));

endfunction