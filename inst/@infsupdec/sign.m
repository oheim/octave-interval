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
## @deftypefn {Interval Function} {@var{Y} =} sign (@var{X})
## @cindex IEEE1788 sign
## 
## Compute the signum function for each number in interval @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sign (infsupdec (2, 3))
##   @result{} [1]_com
## sign (infsupdec (0, 5))
##   @result{} [0, 1]_def
## sign (infsup (-17))
##   @result{} [-1]_com
## @end group
## @end example
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = sign (x)

result = sign (intervalpart (x));
## sign is defined everywhere and continuous for x ~= 0
if (ismember (0, x))
    result = decorateresult (result, {x}, "def");
else
    result = decorateresult (result, {x});
endif

endfunction