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
## @deftypefn {Interval Constructor} {} newdec (@var{X})
## @cindex IEEE1788 newDec
## 
## Create a decorated interval from a bare interval.
##
## @example
## @group
## newdec (infsup (2, 3))
##   @result{} [2, 3]_com
## @end group
## @end example
## @seealso{setdec}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-12

function xd = newdec (x)

xd = infsupdec (x.inf, x.sup);

endfunction