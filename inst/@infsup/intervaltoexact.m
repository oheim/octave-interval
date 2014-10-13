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
## @deftypefn {Interval Output} {@var{S} =} intervaltoexact (@var{X})
## @cindex IEEE1788 intervalToExact
## 
## Build an exact representation of the interval @var{X} in decimal format.
##
## The interval boundaries are stored in binary floating point format and can
## be converted to decimal format without precision loss. The decimal number
## might have a lot of digits.
##
## The equation @code{@var{X} == exacttointerval (intervaltoexact (@var{X}))}
## holds for all intervals @var{X}.
##
## Accuracy: The output is exact.
## @seealso{exacttointerval}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-01

function s = intervaltoexact (x)

s = intervaltotext (x, true ());

endfunction