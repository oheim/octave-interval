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
## @deftypefn {Interval Function} {@var{X} =} mulrev (@var{B}, @var{C}, @var{X})
## @deftypefnx {Interval Function} {@var{X} =} mulrev (@var{B}, @var{C})
## @cindex IEEE1788 mulRev
## 
## Compute the reverse multiplication function.
##
## Accuracy: The result is a tight enclosure.
##
## @seealso{times}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = mulrev (b, c, x)

if (nargin < 2)
    print_usage ();
    return
endif
if (nargin < 3)
    x = infsup (-inf, inf);
endif
if (not (isa (b, "infsup")))
    b = infsup (b);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

assert (isscalar (b) && isscalar (c) && isscalar (x), ...
        "only implemented for interval scalars");

if (isempty (x) || isempty (b) || isempty (c))
    result = infsup ();
    return
endif

if (isentire (b) || isentire (c))
    result = x;
    return
endif

if (b.inf == 0)
    bl = +0;
else
    bl = b.inf;
endif
if (b.sup == 0)
    bu = -0;
else
    bu = b.sup;
endif
if (c.inf == 0)
    cl = +0;
else
    cl = c.inf;
endif
if (c.sup == 0)
    cu = -0;
else
    cu = c.sup;
endif

## We use division by zero below
olddivbyzerowarningstate = warning ("query", "Octave:divide-by-zero").state;
warning ("off", "Octave:divide-by-zero");

if (ismember (0, c))
    if (ismember (0, b))
        result = x;
    elseif (c.inf == 0 && c.sup == 0)
        result = infsup (0);
    elseif (b.sup < 0)
        fesetround (-inf);
        l = cu / bu;
        fesetround (inf);
        u = cl / bu;
        fesetround (0.5);
        result = infsup(l, u) & x;
    else # b.inf > 0
        fesetround (-inf);
        l = cl / bl;
        fesetround (inf);
        u = cu / bl;
        fesetround (0.5);
        result = infsup(l, u) & x;
    endif
elseif (c.sup < 0)
    if (b.inf == 0 && b.sup == 0)
        result = infsup ();
    elseif (b.sup <= 0)
        fesetround (-inf);
        l = cu / bl;
        fesetround (inf);
        u = cl / bu;
        fesetround (0.5);
        result = infsup (l, u) & x;
    elseif (b.inf >= 0)
        fesetround (-inf);
        l = cl / bl;
        fesetround (inf);
        u = cu / bu;
        fesetround (0.5);
        result = infsup (l, u) & x;
    else
        result = x;
    endif
else # c.inf > 0
    if (b.inf == 0 && b.sup == 0)
        result = infsup ();
    elseif (b.sup <= 0)
        fesetround (-inf);
        l = cu / bu;
        fesetround (inf);
        u = cl / bl;
        fesetround (0.5);
        result = infsup (l, u) & x;
    elseif (b.inf >= 0)
        fesetround (-inf);
        l = cl / bu;
        fesetround (inf);
        u = cu / bl;
        fesetround (0.5);
        result = infsup (l, u) & x;
    else
        result = x;
    endif
endif

## Restore old warning settings
warning (olddivbyzerowarningstate, "Octave:divide-by-zero");

endfunction
