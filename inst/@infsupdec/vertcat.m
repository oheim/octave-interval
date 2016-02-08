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
## @defop Method {@@infsupdec} vertcat (@var{ARRAY1}, @var{ARRAY2}, @dots{})
## @defopx Operator {@@infsupdec} {[@var{ARRAY1}; @var{ARRAY2}; @dots{}]}
##
## Return the vertical concatenation of interval array objects along
## dimension 1.
##
## @example
## @group
## a = infsupdec (2, 5);
## [a; a; a]
##   @result{} ans = 3×1 interval vector
##      [2, 5]_com
##      [2, 5]_com
##      [2, 5]_com
## @end group
## @end example
## @seealso{@@infsupdec/horzcat}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-11-02

function result = vertcat (varargin)

varargin = transpose (varargin);

## Conversion to interval
decoratedintervals = cellfun ("isclass", varargin, "infsupdec");
to_convert = not (decoratedintervals);
varargin (to_convert) = cellfun (@infsupdec, varargin (to_convert), ...
                                 "UniformOutput", false ());

nais = cellfun (@isnai, varargin);
if (any (nais))
    ## Simply return first NaI
    result = varargin {find (nais, 1)};
    return
endif

l = cell2mat (cellfun (@inf, varargin, "UniformOutput", false ()));
u = cell2mat (cellfun (@sup, varargin, "UniformOutput", false ()));
d = cell2mat (cellfun (@(x) x.dec, varargin, "UniformOutput", false ()));

result = newdec (infsup (l, u));
result.dec = d;

endfunction

%!xtest assert (isequal (vertcat (infsupdec (1), infsupdec (2)), infsupdec (vertcat (1, 2))));
%!xtest "from the documentation string";
%! a = infsupdec (2, 5);
%! assert (isequal (vertcat (a, a, a), infsupdec ([2; 2; 2], [5; 5; 5])));
