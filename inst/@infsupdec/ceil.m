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
## @deftypefn {Interval Function} {@var{Y} =} ceil (@var{X})
## @cindex IEEE1788 ceil
## 
## Round each number in interval @var{X} towards +Inf.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## ceil (infsupdec (2.5, 3.5))
##   @result{} [3, 4]_def
## ceil (infsupdec (-0.5, 5))
##   @result{} [0, 5]_def
## @end group
## @end example
## @seealso{floor, round, roundb, fix}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = ceil (x)

if (isnai (x))
    result = x;
    return
endif

result = ceil (intervalpart (x));
if (issingleton (result) && fix (x.sup) ~= x.sup)
    ## Between two integral numbers the function is constant, thus continuous
    result = decorateresult (result, {x});
else
    result = decorateresult (result, {x}, "def");
endif

endfunction