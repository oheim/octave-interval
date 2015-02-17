## Copyright 2014-2015 Oliver Heimlich
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
## @deftypefn {Function File} {@var{X} =} atan2rev2 (@var{A}, @var{C}, @var{X})
## @deftypefnx {Function File} {@var{X} =} atan2rev2 (@var{A}, @var{C})
## 
## Compute the reverse atan2 function for the second parameter.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{atan2 (a, x) ∈ @var{C}} for any @code{a ∈ @var{A}}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## atan2rev2 (infsup (1, 2), infsup ("pi") / 4)
##   @result{} [.9999999999999997, 2.0000000000000005]
## @end group
## @end example
## @seealso{@@infsup/atan2}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = atan2rev2 (a, c, x)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif

if (nargin < 3)
    x = infsup (-inf, inf);
endif
if (not (isa (a, "infsup")))
    a = infsup (a);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

assert (isscalar (a) && isscalar (c) && isscalar (x), ...
        "only implemented for interval scalars");

pi = infsup ("pi");

if (isempty (x) || isempty (a) || isempty (c) || ...
    c.inf >= sup (pi) || c.sup <= inf (-pi))
    result = infsup ();
    return
endif

## c1 is the part of c where y >= 0 and x <= 0
c1 = c & infsup (inf (pi) / 2, sup (pi));
if (isempty (c1) || x.inf > 0 || a.sup < 0 || c1.sup == inf (pi) / 2 || ...
    (x.inf >= 0 && a.sup <= 0) || (a.sup <= 0 && c1.inf > inf (pi) / 2))
    result = infsup ();
else
    ## The inverse function is x = a / tan (c)
    ## minimum is located at a.sup, c.sup
    ## maximum is located at a.inf, c.inf
    if (c1.sup >= sup (pi) || a.sup == inf)
        l = -inf;
    else
        l = inf (a.sup ./ tan (infsup (c1.sup)));
    endif
    if (c1.inf <= inf (pi) / 2 || a.inf <= 0)
        u = 0;
    else
        u = sup (a.inf ./ tan (infsup (c1.inf)));
    endif
    result = x & infsup (l, u);
endif

## c2 is the part of c where y >= 0 and x >= 0
c2 = c & infsup (0, sup (pi) / 2);
if (isempty (c2) || x.sup < 0 || a.sup < 0 || c2.inf == sup (pi) / 2 || ...
    (x.sup <= 0 && a.sup <= 0) || (c2.sup <= 0 && a.inf > 0) || ...
    (a.sup <= 0 && c2.inf > 0))
    ## nothing to do
else
    ## The inverse function is x = a / tan (c)
    ## minimum is located at a.inf, c.sup
    ## maximum is located at a.sup, c.inf
    if (c2.sup == 0 || c2.sup >= sup (pi) / 2)
        l = 0;
    else
        l = max (0, inf (a.inf ./ tan (infsup (c2.sup))));
    endif
    if (c2.inf == 0 || c2.sup == 0 || a.sup == inf)
        u = inf;
    else
        u = sup (a.sup ./ tan (infsup (c2.inf)));
    endif
    result = result | (x & infsup (l, u));
endif

## c3 is the part of c where y <= 0 and x >= 0
c3 = c & infsup (inf (-pi) / 2, 0);
if (isempty (c3) || x.sup < 0 || a.inf > 0 || ...
    c3.sup == inf (-pi) / 2 || (x.sup <= 0 && a.inf >= 0) || ...
    (c3.inf >= 0 && a.sup < 0) || (a.inf >= 0 && c3.sup < 0))
    ## nothing to do
else
    ## The inverse function is x = a / tan (c)
    ## minimum is located at a.sup, c.inf
    ## maximum is located at a.inf, c.sup
    if (c3.inf <= inf (-pi) / 2 || c3.inf == 0)
        l = 0;
    else
        l = max (0, inf (a.sup ./ tan (infsup (c3.inf))));
    endif
    if (c3.inf == 0 || c3.sup == 0 || a.inf == inf)
        u = inf;
    else
        u = sup (a.inf ./ tan (infsup (c3.sup)));
    endif
    result = result | (x & infsup (l, u));
endif

## c4 is the part of c where y <= 0 and x <= 0
c4 = c & infsup (inf (-pi), sup (-pi) / 2);
if (isempty (c4) || x.inf > 0 || a.inf > 0 || ...
    c4.inf == sup (-pi) / 2 || (x.inf >= 0 && a.inf >= 0) || ...
    (a.inf >= 0 && c4.inf > inf (-pi)))
    ## nothing to do
else
    ## The inverse function is x = a / tan (c)
    ## minimum is located at a.inf, c.inf
    ## maximum is located at a.sup, c.sup
    if (c4.inf <= inf (-pi) || a.inf == -inf)
        l = -inf;
    else
        l = inf (a.inf ./ tan (infsup (c4.inf)));
    endif
    if (c4.sup >= sup (-pi) / 2 || a.sup >= 0)
        u = 0;
    else
        u = sup (a.sup ./ tan (infsup (c4.sup)));
    endif
    result = result | (x & infsup (l, u));
endif
endfunction
