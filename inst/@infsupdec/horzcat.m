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

## @deftypefn {Interval Constructor} {} horzcat (@var{ARRAY}…)
##
## Return the horizontal concatenation of interval array objects along
## dimension 2.
## @seealso{vertcat}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-11-02

function result = horzcat (varargin)

l = u = dx = cell (1, nargin);

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
dx = horzcat (dx {:});

result = infsupdec (l, u, dx);

endfunction