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
## @deftypefn {Function File} {} sqrt (@var{X})
## 
## Compute the square root for all non-negative numbers in @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sqrt (infsupdec (-6, 4))
##   @result{} [0, 2]_trv
## @end group
## @end example
## @seealso{sqr, pow}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = sqrt (x)

if (isnai (x))
    result = x;
    return
endif

result = infsupdec (sqrt (intervalpart (x)));
result.dec = mindec (result.dec, x.dec);

## sqrt is continuous everywhere, but defined for x >= 0 only
defined = subset (x, infsup (0, inf));
result (not (defined)) = "trv";

endfunction