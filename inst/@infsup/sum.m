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
## @deftypefn {Interval Function} {@var{Z} =} sum (@var{X}…)
## @cindex IEEE1788 sum
## 
## Compute the sum of a list of intervals.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sum (infsup (1), pow2 (-1074), -1)
##   @result{} [4e-324, 5e-324]
## infsup (1) + pow2 (-1074) - 1
##   @result{} [0, 2.2204460492503131e-16]
## @end group
## @end example
## @seealso{minus}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function [result, isexact] = sum (varargin)

if (nargin == 0)
    result = infsup ();
    isexact = true ();
    return
endif

## Initialize accumulators
l.e = int64 (0);
l.m = [];
l.unbound = false ();
u.e = int64 (0);
u.m = [];
u.unbound = false ();

for i = 1 : nargin
    ## Convert to interval, if necessary
    if (not (isa (varargin {i}, "infsup")))
        interval = infsup (varargin {i});
    else
        interval = varargin {i};
    endif
    
    if (isempty (interval))
        result = infsup ();
        isexact = true ();
        return
    endif
    if (isfinite (interval.inf))
        if (not (l.unbound))
            l = accuadd (l, interval.inf);
        endif
    else
        l.unbound = true ();
    endif
    if (isfinite (interval.sup))
        if (not (u.unbound))
            u = accuadd (u, interval.sup);
        endif
    else
        u.unbound = true ();
    endif
endfor

if (l.unbound)
    l = -inf;
    isexact = true ();
else
    [l, isexact] = accu2double (l, -inf);
endif

if (u.unbound)
    u = inf;
else
    [u, upperisexact] = accu2double (u, inf);
    isexact = or (isexact, upperisexact);
endif

result = infsup (l, u);

endfunction