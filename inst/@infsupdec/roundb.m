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
## @deftypefn {Interval Function} {@var{Y} =} roundb (@var{X})
## @cindex IEEE1788 roundTiesToEven
## 
## Round each number in interval @var{X} to the nearest integer.  Ties are
## rounded towards the nearest even integer.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## roundb (infsupdec (2.5, 3.5))
##   @result{} [2, 4]_def
## roundb (infsupdec (-0.5, 5.5))
##   @result{} [0, 6]_def
## @end group
## @end example
## @seealso{floor, ceil, round, fix}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = roundb (x)


result = roundb (intervalpart (x));
if (issingleton (result) && ...
    (rem (result.inf, 2) ~= 0 ||
        ((fix (x.sup) == x.sup || fix (x.sup * 2) / 2 ~= x.sup) && ...
         (fix (x.inf) == x.inf || fix (x.inf * 2) / 2 ~= x.inf))))
    result = decorateresult (result, {x});
else
    result = decorateresult (result, {x}, "def");
endif

endfunction