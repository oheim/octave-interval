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
## @deftypefn {Interval Function} {@var{Y} =} atanh (@var{X})
## @cindex IEEE1788 atanh
## 
## Compute the inverse hyperbolic tangent for each number in interval @var{X}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## atanh (infsup (.5))
##   @result{} [.5493061443340547, .5493061443340549]
## @end group
## @end example
## @seealso{tanh}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function result = atanh (x)

if (isempty (x) || x.sup <= -1 || x.inf >= 1)
    result = empty ();
    return
endif

if (x.inf == -1)
    ath.inf = -inf;
elseif (x.inf == 0)
    ath.inf = 0;
else
    fesetround (-inf);
    ath.inf = atanh (x.inf);
endif

if (x.sup == 1)
    ath.sup = inf;
elseif (x.sup == 0)
    ath.sup = 0;
else
    fesetround (inf);
    ath.sup = atanh (x.sup);
endif
fesetround (0.5);

result = infsup (ath.inf, ath.sup);

endfunction