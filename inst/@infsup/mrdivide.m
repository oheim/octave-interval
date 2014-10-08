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
## @deftypefn {Interval Function} {@var{Z} =} @var{X} / @var{Y}
## @cindex IEEE1788 div
## 
## Divide all numbers of interval @var{X} by all numbers of @var{Y}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## x / y
##   @result{} [1, 3]
## @end group
## @end example
## @seealso{mtimes}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = mrdivide (x, y)

## Convert divisor into interval, if necessary
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

if (isempty (x) || isempty (y))
    result = empty ();
    return
endif

if ((y.inf < 0 && y.sup > 0) || ...
    (x.inf <= 0 && x.sup >= 0 && y.inf == 0 && y.sup == 0))
    result = entire ();
    return
endif

if ((x.sup < 0 || x.inf > 0) && y.inf == 0 && y.sup == 0)
    result = empty ();
endif

if (x.sup <= 0)
    if (y.sup < 0)
        fesetround (-inf);
        quot.inf = x.sup / y.inf;
        fesetround (inf);
        quot.sup = x.inf / y.sup;
    elseif (y.inf > 0)
        fesetround (-inf);
        quot.inf = x.inf / y.inf;
        fesetround (inf);
        quot.sup = x.sup / y.sup;
    elseif (y.sup == 0)
        fesetround (-inf);
        quot.inf = x.sup / y.inf;
        quot.sup = 1;
    else # y.inf == 0
        quot.inf = -1;
        fesetround (inf);
        quot.sup = x.sup / y.sup;
    endif
elseif (x.inf >= 0)
    if (y.sup < 0)
        fesetround (-inf);
        quot.inf = x.sup / y.sup;
        fesetround (inf);
        quot.sup = x.inf / y.inf;
    elseif (y.inf > 0)
        fesetround (-inf);
        quot.inf = x.inf / y.sup;
        fesetround (inf);
        quot.sup = x.sup / y.inf;
    elseif (y.sup == 0)
        quot.inf = -1;
        fesetround (inf);
        quot.sup = x.inf / y.inf;
    else # y.inf == 0
        fesetround (-inf);
        quot.inf = x.inf / y.sup;
        quot.sup = 1;
    endif
else
    if (y.sup < 0)
        fesetround (-inf);
        quot.inf = x.sup / y.sup;
        fesetround (inf);
        quot.sup = x.inf / y.sup;
    else # y.inf > 0
        fesetround (-inf);
        quot.inf = x.inf / y.inf;
        fesetround (inf);
        quot.sup = x.sup / y.inf;
    endif
endif

fesetround (0.5);

result = infsup (quot.inf, quot.sup);

endfunction