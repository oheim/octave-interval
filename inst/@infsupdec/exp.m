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
## @deftypefn {Interval Function} {} exp (@var{X})
## @cindex IEEE1788 exp
## 
## Compute the exponential function for all numbers in @var{X}.
##
## Accuracy: The result is an accurate enclosure.  The result is tightest for
## boundaries @code{0} and @code{1}.
##
## @example
## @group
## exp (infsupdec (1))
##   @result{} [2.718281828459045, 2.7182818284590456]_com
## @end group
## @end example
## @seealso{log, pow}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = exp (x)

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (exp (intervalpart (x)));
## exp is defined and continuous everywhere
result.dec = mindec (result.dec, x.dec);

endfunction