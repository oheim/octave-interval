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
## @deftypefn {Interval Function} {@var{Y} =} tan (@var{X})
## @cindex IEEE1788 tan
## 
## Compute the tangent for each number in interval @var{X} in radians.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## tan (infsupdec (1))
##   @result{} [1.557407724654902, 1.5574077246549026]_com
## @end group
## @end example
## @seealso{atan, tanh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = tan (x)

if (isnai (x))
    result = x;
    return
endif

result = tan (intervalpart (x));

if (isentire (result))
    ## Because tan (nextdown (pi / 2)) < realmax, we can simple check for
    ## a singularity by comparing the result with entire.
    result = decorateresult (result, {x}, "trv");
else
    ## tan has been evaluated where it is defined and continuous
    result = decorateresult (result, {x});
endif

endfunction