## Copyright 2015 Oliver Heimlich
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
## @deftypefn {Function File} {} reducedec (@var{X}, @var{DIM})
## 
## For an array of decorations, determine the worst (minimum) decoration of all
## elements along a given dimension.
##
## @example
## @group
## reducedec ({"com", "dac", "def"; "com", "com", "trv"}, 1)
##   @result{} {"com", "dac", "trv"}
## @end group
## @end example
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-01-31

function result = reducedec (x, dim)

if (strcmp (x, "ill"))
    result = x;
    return
endif

resultsize = size (x);
resultsize (dim) = 1;
result = cell (resultsize);

## Initialize with best possible decoration and then degrade as necessary
result (:) = "com";
for d = {"dac", "def", "trv"}
    result (any (strcmp (x, d), dim)) = d;
endfor

endfunction
