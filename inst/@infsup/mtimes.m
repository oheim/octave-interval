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
## @deftypefn {Interval Function} {@var{Z} =} @var{X} * @var{Y}
## @cindex IEEE1788 mul
## 
## Multiply all numbers of interval @var{X} by all numbers of @var{Y}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## x * y
##   @result{} [2, 6]
## @end group
## @end example
## @seealso{mrdivide}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = mtimes (x, y)

## Convert multiplier into interval, if necessary
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

if (isempty (x) || isempty (y))
    result = empty ();
    return
endif

if ((x.inf == 0 && x.sup == 0) || ...
    (y.inf == 0 && y.sup == 0))
    result = infsup (0, 0);
    return
endif

if (isentire (x) || isentire (y))
    result = entire ();
    return
endif

if (y.sup <= 0)
    if (x.sup <= 0)
        fesetround (-inf);
        prod.inf = x.sup * y.sup;
        fesetround (inf);
        prod.sup = x.inf * y.inf;
    elseif (x.inf >= 0)
        fesetround (-inf);
        prod.inf = x.sup * y.inf;
        fesetround (inf);
        prod.sup = x.inf * y.sup;
    else
        fesetround (-inf);
        prod.inf = x.sup * y.inf;
        fesetround (inf);
        prod.sup = x.inf * y.inf;
    endif
elseif (y.inf >= 0)
    if (x.sup <= 0)
        fesetround (-inf);
        prod.inf = x.inf * y.sup;
        fesetround (inf);
        prod.sup = x.sup * y.inf;
    elseif (x.inf >= 0)
        fesetround (-inf);
        prod.inf = x.inf * y.inf;
        fesetround (inf);
        prod.sup = x.sup * y.sup;
    else
        fesetround (-inf);
        prod.inf = x.inf * y.sup;
        fesetround (inf);
        prod.sup = x.sup * y.sup;
    endif
else
    if (x.sup <= 0)
        fesetround (-inf);
        prod.inf = x.inf * y.sup;
        fesetround (inf);
        prod.sup = x.inf * y.inf;
    elseif (x.inf >= 0)
        fesetround (-inf);
        prod.inf = x.sup * y.inf;
        fesetround (inf);
        prod.sup = x.sup * y.sup;
    else
        fesetround (-inf);
        prod.inf = min (x.inf * y.sup, x.sup * y.inf);
        fesetround (inf);
        prod.sup = max (x.inf * y.inf, x.sup * y.sup);
    endif
endif

fesetround (0.5);

result = infsup (prod.inf, prod.sup);

endfunction