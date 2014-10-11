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
## @deftypefn {Interval Function} {@var{Y} =} log10 (@var{X})
## @cindex IEEE1788 log10
## 
## Compute the decimal (base-10) logarithm for all numbers in interval @var{X}.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## log10 (infsup (2))
##   @result{} [.30102999566398114, .3010299956639812]
## @end group
## @end example
## @seealso{pow10, log, log2}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = log10 (x)

if (isempty (x) || x.sup <= 0)
    result = empty ();
    return
endif

if (x.inf <= 0)
    l.inf = -inf;
else
    fesetround  (-inf);
    l.inf = log10 (x.inf);
endif

fesetround (inf);
l.sup = log10 (x.sup);
fesetround (0.5);

result = infsup (l.inf, l.sup);

endfunction