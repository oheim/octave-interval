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
## @deftypefn {Interval Function} {@var{Z} =} dot (@var{X}, @var{Y})
## @cindex IEEE1788 dot
## 
## Compute the dot product between two vectors of intervals.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## dot ([infsup(1), 2, 3], [infsup(2), 3, 4])
##   @result{} [20]
## @end group
## @end example
## @seealso{plus, sum, mtimes, sumabs, sumsquare}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function [result, isexact] = dot (x, y)

assert (nargin == 2);
assert (length (x) == length (y), "length mismatch");

if (length (x) == 0)
    result = infsup ();
    isexact = true ();
    return
endif

## Initialize accumulators
l.e = int64 (0);
l.m = zeros (1, 0, "int8");
l.unbound = false ();
u.e = int64 (0);
u.m = zeros (1, 0, "int8");
u.unbound = false ();

for i = 1:length(x)
    if (isempty (x (i)) || isempty (y (i)))
        result = infsup ();
        isexact = true ();
        return
    endif
    
    x_inf = inf (x (i));
    x_sup = sup (x (i));
    y_inf = inf (y (i));
    y_sup = sup (y (i));
    
    if ((x_inf == 0 && x_sup == 0) || ...
        (y_inf == 0 && y_sup == 0))
        continue
    endif
    
    if (y_sup <= 0)
        if (x_sup <= 0)
            if (not (l.unbound))
                l = accuaddproduct (l, x_sup, y_sup);
            endif
            if (not (isfinite (x_inf) && isfinite (y_inf)))
                u.unbound = true ();
            elseif (not (u.unbound))
                u = accuaddproduct (u, x_inf, y_inf);
            endif
        elseif (x_inf >= 0)
            if (not (isfinite (x_sup) && isfinite (y_inf)))
                l.unbound = true ();
            elseif (not (l.unbound))
                l = accuaddproduct (l, x_sup, y_inf);
            endif
            if (not (u.unbound))
                 u = accuaddproduct (u, x_inf, y_sup);
            endif
        else
            if (not (isfinite (x_sup) && isfinite (y_inf)))
                l.unbound = true ();
            elseif (not (l.unbound))
                l = accuaddproduct (l, x_sup, y_inf);
            endif
            if (not (isfinite (x_inf) && isfinite (y_inf)))
                u.unbound = true ();
            elseif (not (u.unbound))
                u = accuaddproduct (u, x_inf, y_inf);
            endif
        endif
    elseif (y_inf >= 0)
        if (x_sup <= 0)
            if (not (isfinite (x_inf) && isfinite (y_sup)))
                l.unbound = true ();
            elseif (not (l.unbound))
                l = accuaddproduct (l, x_inf, y_sup);
            endif
            if (not (u.unbound))
                u = accuaddproduct (u, x_sup, y_inf);
            endif
        elseif (x_inf >= 0)
            if (not (l.unbound))
                l = accuaddproduct (l, x_inf, y_inf);
            endif
            if (not (isfinite (x_sup) && isfinite (y_sup)))
                u.unbound = true ();
            elseif (not (u.unbound))
                u = accuaddproduct (u, x_sup, y_sup);
            endif
        else
            if (not (isfinite (x_inf) && isfinite (y_sup)))
                l.unbound = true ();
            elseif (not (l.unbound))
                l = accuaddproduct (l, x_inf, y_sup);
            endif
            if (not (isfinite (x_sup) && isfinite (y_sup)))
                u.unbound = true ();
            elseif (not (u.unbound))
                u = accuaddproduct (u, x_sup, y_sup);
            endif
        endif
    else
        if (x_sup <= 0)
            if (not (isfinite (x_inf) && isfinite (y_sup)))
                l.unbound = true ();
            elseif (not (l.unbound))
                l = accuaddproduct (l, x_inf, y_sup);
            endif
            if (not (isfinite (x_inf) && isfinite (y_inf)))
                u.unbound = true ();
            elseif (not (u.unbound))
                u = accuaddproduct (u, x_inf, y_inf);
            endif
        elseif (x_inf >= 0)
            if (not (isfinite (x_sup) && isfinite (y_inf)))
                l.unbound = true ();
            elseif (not (l.unbound))
                l = accuaddproduct (l, x_sup, y_inf);
            endif
            if (not (isfinite (x_sup) && isfinite (y_sup)))
                u.unbound = true ();
            elseif (not (u.unbound))
                u = accuaddproduct (u, x_sup, y_sup);
            endif
        else
            if (not (isfinite (x_inf) && isfinite (x_sup) && ...
                     isfinite (y_inf) && isfinite (y_sup)))
                l.unbound = true ();
                u.unbound = true ();
            else
                if (not (l.unbound))
                    if (x_inf * y_sup < x_sup * y_inf)
                        l = accuaddproduct (l, x_inf, y_sup);
                    else
                        l = accuaddproduct (l, x_sup, y_inf);
                    endif
                endif
                if (not (u.unbound))
                    if (x_inf * y_inf > x_sup * y_sup)
                        u = accuaddproduct (u, x_inf, y_inf);
                    else
                        u = accuaddproduct (u, x_sup, y_sup);
                    endif
                endif
            endif
        endif
    endif
endfor

if (l.unbound)
    l = -inf
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