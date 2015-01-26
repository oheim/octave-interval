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
## @deftypefn {Function File} {} ndims (@var{A})
##
## Return the number of dimensions of @var{A}.
##
## For any array, the result will always be larger than or equal to 2.
## Trailing singleton dimensions are not counted.
## @seealso{@@infsup/length, @@infsup/numel, @@infsup/size, @@infsup/rows, @@infsup/columns}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

function result = ndims (a)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = ndims (a.inf);

endfunction
