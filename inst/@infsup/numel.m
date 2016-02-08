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
## @defmethod {@@infsup} numel (@var{A})
##
## Return the number of elements in the interval object @var{A}.
## @seealso{@@infsup/length, @@infsup/size, @@infsup/rows, @@infsup/columns}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

function result = numel (a)

if (nargin ~= 1)
    print_usage ();
    return
endif

result = numel (a.inf);

endfunction

%!assert (numel (infsup ([])), 0);
%!assert (numel (infsup (0)), 1);
%!assert (numel (infsup (zeros (3, 1))), 3);
%!assert (numel (infsup (zeros (1, 4))), 4);
%!assert (numel (infsup (zeros (3, 4))), 12);
