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
## @deftypefn {Interval Function} {@var{Y} =} log (@var{X})
## @cindex IEEE1788 log
## 
## Compute the natural logarithm for all numbers in interval @var{X}.
##
## The function is only defined where @var{X} is positive.
##
## Accuracy: The result is an accurate enclosure.
##
## @example
## @group
## log (infsup (2))
##   @result{} [.6931471805599451, .6931471805599454]
## @end group
## @end example
## @seealso{exp, log2, log10}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = log (x)

if (isempty (x) || x.sup <= 0)
    result = infsup ();
    return
endif

if (x.inf <= 0)
    l.inf = -inf;
elseif (x.inf == 1)
    l.inf = 0;
else
    l.inf = nextdown (log (x.inf));
endif

if (x.sup == 1)
    l.sup = 0;
else
    l.sup = nextup (log (x.sup));
endif

result = infsup (l.inf, l.sup);

endfunction