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
## @deftypefn {Interval Function} {} tanh (@var{X})
## @cindex IEEE1788 tanh
## 
## Compute the hyperbolic tangent for each number in interval @var{X}.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 7 ULPs of the exact enclosure.
##
## @example
## @group
## tanh (infsupdec (1))
##   @result{} [.7615941559557644, .7615941559557653]_com
## @end group
## @end example
## @seealso{atanh, sinh, cosh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = tanh (x)

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (tanh (intervalpart (x)));
## tanh is defined and continuous everywhere
result.dec = mindec (result.dec, x.dec);

endfunction