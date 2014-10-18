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
## @deftypefn {Interval Function} {@var{Y} =} log2 (@var{X})
## @cindex IEEE1788 log2
## 
## Compute the binary (base-2) logarithm for all numbers in interval @var{X}.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## log2 (infsup (2))
##   @result{} [1]
## @end group
## @end example
## @seealso{pow2, log, log10}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = log2 (x)

if (isempty (x) || x.sup <= 0)
    result = infsup ();
    return
endif

if (x.inf <= 0)
    l.inf = -inf;
else
    l.inf = log2 (x.inf);
    if (fix (l.inf) ~= l.inf || l.inf < -1074 || l.inf > 1023 || ...
        pow2 (l.inf) ~= x.inf)
        l.inf = nextdown (l.inf);
    endif
endif

l.sup = log2 (x.sup);
if (fix (l.sup) ~= l.sup || l.sup < -1074 || l.sup > 1023 || ...
    pow2 (l.sup) ~= x.sup)
    l.sup = nextup (l.sup);
endif

result = infsup (l.inf, l.sup);

endfunction