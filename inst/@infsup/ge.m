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

## usage: A >= B
##
## Compare intervals A and B for weakly greater.
##
## Implement the greater or equal operator on intervals for convenience.
##
## See also:
##  less

## Author: Oliver Heimlich
## Keywords: interval comparison operator
## Created: 2014-10-07

function result = ge(a, b)

## Convert second parameter into interval, if necessary
if (not (isa (b, "infsup")))
    b = infsup (b);
endif

result = less (b, a);

endfunction