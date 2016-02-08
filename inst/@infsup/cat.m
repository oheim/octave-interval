## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsup} cat (@var{DIM}, @var{MATRIX1}, @var{MATRIX2}, @dots{})
##
## Return the concatenation of interval matrices @var{MATRIX1}, @var{MATRIX2}, 
## … along dimension @var{DIM}.
##
## Interval matrices support no more than 2 dimensions.
##
## @example
## @group
## cat (2, infsup (magic (3)), infsup (pascal (3)))
##   @result{} 3×6 interval matrix
## 
##      [8]   [1]   [6]   [1]   [1]   [1]
##      [3]   [5]   [7]   [1]   [2]   [3]
##      [4]   [9]   [2]   [1]   [3]   [6]
## @end group
## @end example
## @seealso{@@infsup/horzcat, @@infsup/vertcat}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-04-19

function result = cat (dim, varargin)

switch dim
    case 1
        result = vertcat (varargin {:});
    case 2
        result = horzcat (varargin {:});
    otherwise
        error ("interval:InvalidOperand", ...
               "cat: no more than 2 dimensions are supported")
endswitch

endfunction

%!assert (size (cat (1, infsup ([]), infsup ([]))), [0 0]);
%!assert (cat (1, infsup (1), infsup (2)) == infsup (cat (1, 1, 2)));
%!assert (cat (2, infsup (1), infsup (2)) == infsup (cat (2, 1, 2)));
