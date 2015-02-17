## Copyright 2014-2015 Oliver Heimlich
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
## @deftypefn {Function File} {} {} [@var{ARRAY1}; @var{ARRAY2}; ...]
##
## Return the vertical concatenation of interval array objects along
## dimension 1.
##
## @example
## @group
## a = infsupdec (2, 5);
## [a; a; a]
##   @result{} 3×1 interval vector
##
##      [2, 5]_com
##      [2, 5]_com
##      [2, 5]_com
## @end group
## @end example
## @seealso{@@infsupdec/horzcat}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-11-02

function result = vertcat (varargin)

l = u = dx = cell (nargin, 1);

for i = 1 : nargin
    if (not (isa (varargin {i}, "infsupdec")))
        varargin {i} = infsupdec (varargin {i});
    endif
    l {i} = inf (varargin {i});
    u {i} = sup (varargin {i});
    dx {i} = decorationpart (varargin {i});
endfor

l = cell2mat (l);
u = cell2mat (u);
dx = vertcat (dx {:});

result = infsupdec (l, u, dx);

endfunction