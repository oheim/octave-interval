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
## @deftypefn {Interval Function} {@var{Z} =} sumabs (@var{X}…)
## @cindex IEEE1788 sumAbs
## 
## Compute the sum of absolute values of a list of intervals.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sumabs (infsup (1), pow2 (-1074), -1)
##   @result{} [2, 2.0000000000000005]
## @end group
## @end example
## @seealso{sum, plus, abs}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function [result, isexact] = sumabs (varargin)

if (nargin == 0)
    result = infsup ();
    isexact = true ();
    return
endif

## Initialize accumulators
l.e = int64 (0);
l.m = zeros (1, 0, "int8");
u.e = int64 (0);
u.m = zeros (1, 0, "int8");
u.unbound = false ();

for i = 1 : nargin
    ## Convert to interval, if necessary
    if (not (isa (varargin {i}, "infsup")))
        varargin {i} = infsup (varargin {i});
    endif
    
    if (isempty (varargin {i}))
        result = infsup ();
        isexact = true ();
        return
    endif
    varargin {i} = abs (varargin {i});
    l = accuadd (l, inf (varargin {i}));
    if (isfinite (sup (varargin {i})))
        if (not (u.unbound))
            u = accuadd (u, sup (varargin {i}));
        endif
    else
        u.unbound = true ();
    endif
endfor

[l, isexact] = accu2double (l, -inf);

if (u.unbound)
    u = inf;
else
    [u, upperisexact] = accu2double (u, inf);
    isexact = or (isexact, upperisexact);
endif

result = infsup (l, u);

endfunction