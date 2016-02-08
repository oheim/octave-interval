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
## @defop Method {@@infsup} vertcat (@var{ARRAY1}, @var{ARRAY2}, @dots{})
## @defopx Operator {@@infsup} {[@var{ARRAY1}; @var{ARRAY2}; @dots{}]}
##
## Return the vertical concatenation of interval array objects along
## dimension 1.
##
## @example
## @group
## a = infsup (2, 5);
## [a; a; a]
##   @result{} ans = 3×1 interval vector
##      [2, 5]
##      [2, 5]
##      [2, 5]
## @end group
## @end example
## @seealso{@@infsup/horzcat}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

function result = vertcat (varargin)

varargin = transpose (varargin);

## Conversion to interval
intervals = cellfun ("isclass", varargin, "infsup");
to_convert = not (intervals);
varargin (to_convert) = cellfun (@infsup, varargin (to_convert), ...
                                 "UniformOutput", false ());

l = cell2mat (cellfun (@(x) x.inf, varargin, "UniformOutput", false ()));
u = cell2mat (cellfun (@(x) x.sup, varargin, "UniformOutput", false ()));

result = infsup (l, u);

endfunction

%!assert (vertcat (infsup (1), infsup (2)) == infsup (vertcat (1, 2)));
%!test "from the documentation string";
%! a = infsup (2, 5);
%! assert (vertcat (a, a, a) == infsup ([2; 2; 2], [5; 5; 5]));
