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

## @deftypefn {Interval Constructor} {} [@var{ARRAY1}; @var{ARRAY2}; ...]
##
## Return the vertical concatenation of interval array objects along
## dimension 1.
##
## @example
## @group
## a = infsup (2, 5);
## [a; a; a]
##   @result{} 3×1 interval vector
##
##      [2, 5]
##      [2, 5]
##      [2, 5]
## @end group
## @end example
## @seealso{horzcat}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-29

function result = vertcat (varargin)

l = u = cell (nargin, 1);

for i = 1 : nargin
    if (not (isa (varargin {i}, "infsup")))
        varargin {i} = infsup (varargin {i});
    endif
    l {i} = inf (varargin {i});
    u {i} = sup (varargin {i});
endfor

l = cell2mat (l);
u = cell2mat (u);

result = infsup (l, u);

endfunction