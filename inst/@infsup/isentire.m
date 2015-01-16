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
## @documentencoding utf-8
## @deftypefn {Function File} {} isentire (@var{X})
## 
## Check if the interval represents the entire set of real numbers.
##
## Evaluated on interval matrices, this functions is applied element-wise.
##
## @seealso{eq, isempty, issingleton}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-27

function result = isentire (interval)

result = (interval.inf == -inf & interval.sup == inf);
return