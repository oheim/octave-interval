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
## @deftypefn {Interval Function} {@var{Z} =} cancelplus (@var{X}, @var{Y})
## @cindex IEEE1788 cancelPlus
## 
## Recover interval @var{Z} from intervals @var{X} and @var{Y}, given that one
## knows @var{X} was obtained as the difference @var{Z} - @var{Y}.
##
## Accuracy: The result is a tight enclosure.
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = cancelplus (x, y)

assert (nargin == 2);

result = cancelminus (x, -y);

endfunction