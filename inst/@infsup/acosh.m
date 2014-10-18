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
## @deftypefn {Interval Function} {@var{Y} =} acosh (@var{X})
## @cindex IEEE1788 acosh
## 
## Compute the inverse hyperbolic cosine for each number in interval @var{X}.
##
## Accuracy: The result is a valid enclosure.  Interval boundaries are within
## 8 ULPs of the exact enclosure.
##
## @example
## @group
## acosh (infsup (2))
##   @result{} [1.3169578969248156, 1.3169578969248175]
## @end group
## @end example
## @seealso{cosh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = acosh (x)

if (isempty (x) || x.sup < 1)
    result = infsup ();
    return
endif

if (x.inf <= 1)
    ach.inf = 0;
else
    ## Most implementations should be within 2 ULP, but must guarantee 4 ULP.
    ach.inf = max (0, ulpadd (acosh (x.inf), -4));
endif

if (x.sup == 1)
    ach.sup = 0;
else
    ach.sup = ulpadd (acosh (x.sup), 4);
endif

result = infsup (ach.inf, ach.sup);

endfunction