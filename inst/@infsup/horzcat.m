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
## @defop Method {@@infsup} horzcat (@var{ARRAY1}, @var{ARRAY2}, @dots{})
## @defopx Operator {@@infsup} {[@var{ARRAY1}, @var{ARRAY2}, @dots{}]}
##
## Return the horizontal concatenation of interval array objects along
## dimension 2.
##
## @example
## @group
## a = infsup (2, 5);
## [a, a, a]
##   @result{} ans = 1×3 interval vector
##      [2, 5]   [2, 5]   [2, 5]
## @end group
## @end example
## @seealso{@@infsup/vertcat}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

function result = horzcat (varargin)

## Conversion to interval
intervals = cellfun ("isclass", varargin, "infsup");
to_convert = not (intervals);
varargin (to_convert) = cellfun (@infsup, varargin (to_convert), ...
                                 "UniformOutput", false ());

l = cell2mat (cellfun (@(x) x.inf, varargin, "UniformOutput", false ()));
u = cell2mat (cellfun (@(x) x.sup, varargin, "UniformOutput", false ()));

result = infsup (l, u);

endfunction

%!assert (horzcat (infsup (1), infsup (2)) == infsup (horzcat (1, 2)));
%!test "from the documentation string";
%! a = infsup (2, 5);
%! assert (horzcat (a, a, a) == infsup ([2, 2, 2], [5, 5, 5]));
