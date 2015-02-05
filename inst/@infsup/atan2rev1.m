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
## @deftypefn {Function File} {@var{Y} =} atan2rev1 (@var{B}, @var{C}, @var{Y})
## @deftypefnx {Function File} {@var{Y} =} atan2rev1 (@var{B}, @var{C})
## 
## Compute the reverse atan2 function for the first parameter.
##
## That is, an enclosure of all @code{y ∈ @var{Y}} where
## @code{atan2 (y, b) ∈ @var{C}} for any @code{b ∈ @var{B}}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## atan2rev1 (infsup (1, 2), infsup ("pi") / 4)
##   @result{} [.9999999999999998, 2.0000000000000005]
## @end group
## @end example
## @seealso{@@infsup/atan2}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = atan2rev1 (b, c, y)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif

if (nargin < 3)
    y = infsup (-inf, inf);
endif
if (not (isa (b, "infsup")))
    b = infsup (b);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

assert (isscalar (b) && isscalar (c) && isscalar (y), ...
        "only implemented for interval scalars");

pi = infsup ("pi");

if (isempty (y) || isempty (b) || isempty (c) || ...
    c.inf >= sup (pi) || c.sup <= inf (-pi))
    result = infsup ();
    return
endif

## c1 is the part of c where y >= 0 and x <= 0
c1 = c & infsup (inf (pi) / 2, sup (pi));
if (isempty (c1) || b.inf > 0 || y.sup < 0 || c1.sup == inf (pi) / 2 || ...
    (b.inf >= 0 && y.sup <= 0) || (b.inf >= 0 && c1.inf > inf (pi) / 2))
    result = infsup ();
else
    ## The inverse function is y = b * tan (c)
    ## minimum is located at b.sup, c.sup
    ## maximum is located at b.inf, c.inf
    if (c1.sup >= sup (pi) || b.sup >= 0)
        l = 0;
    else
        l = max (0, inf (b.sup * tan (infsup (c1.sup))));
    endif
    if (c1.inf <= inf (pi) / 2 || b.inf == -inf)
        u = inf;
    else
        u = sup (b.inf .* tan (infsup (c1.inf)));
    endif
    result = y & infsup (l, u);
endif

## c2 is the part of c where y >= 0 and x >= 0
c2 = c & infsup (0, sup (pi) / 2);
if (isempty (c2) || b.sup < 0 || y.sup < 0 || c2.inf == sup (pi) / 2 || ...
    (b.sup <= 0 && y.sup <= 0) || (b.sup <= 0 && c2.sup < sup (pi) / 2))
    ## nothing to do
else
    ## The inverse function is y = b * tan (c)
    ## minimum is located at b.inf, c.inf
    ## maximum is located at b.sup, c.sup
    if (c2.inf <= 0 || b.inf <= 0)
        l = 0;
    else
        l = max (0, inf (b.inf .* tan (infsup (c2.inf))));
    endif
    if (c2.sup == 0)
        u = 0;
    elseif (c2.sup >= sup (pi) / 2 || b.sup == inf)
        u = inf;
    else
        u = sup (b.sup .* tan (infsup (c2.sup)));
    endif
    result = result | (y & infsup (l, u));
endif

## c3 is the part of c where y <= 0 and x >= 0
c3 = c & infsup (inf (-pi) / 2, 0);
if (isempty (c3) || b.sup < 0 || y.inf > 0 || ...
    c3.sup == inf (-pi) / 2 || (b.sup <= 0 && y.inf >= 0) || ...
    (b.sup <= 0 && c2.inf > inf (-pi) / 2))
    ## nothing to do
else
    ## The inverse function is y = b * tan (c)
    ## minimum is located at b.sup, c.inf
    ## maximum is located at b.inf, c.sup
    if (c3.inf == 0)
        l = 0;
    elseif (c3.inf <= inf (-pi) / 2 || b.sup == inf)
        l = -inf;
    else
        l = inf (b.sup .* tan (infsup (c3.inf)));
    endif
    if (c3.sup == 0 || b.inf <= 0)
        u = 0;
    else
        u = sup (b.inf .* tan (infsup (c3.sup)));
    endif
    result = result | (y & infsup (l, u));
endif

## c4 is the part of c where y <= 0 and x <= 0
c4 = c & infsup (inf (-pi), sup (-pi) / 2);
if (isempty (c4) || b.inf > 0 || y.inf > 0 || ...
    c4.inf == sup (-pi) / 2 || (b.inf >= 0 && y.inf >= 0) || ...
    (b.inf >= 0 && c4.sup < sup (-pi) / 2))
    ## nothing to do
else
    ## The inverse function is y = b * tan (c)
    ## minimum is located at b.inf, c.sup
    ## maximum is located at b.sup, c.inf
    if (c4.sup >= sup (-pi) / 2 || b.inf == -inf)
        l = -inf;
    else
        l = inf (b.inf .* tan (infsup (c4.sup)));
    endif
    if (c4.inf <= inf (-pi) || b.sup >= 0)
        u = 0;
    else
        u = min (0, sup (b.sup .* tan (infsup (c4.sup))));
    endif
    result = result | (y & infsup (l, u));
endif
endfunction
