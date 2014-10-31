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
## @deftypefn {Interval Function} {} dot (@var{X}, @var{Y})
## @deftypefnx {Interval Function} {} dot (@var{X}, @var{Y}, @var{DIM})
## @cindex IEEE1788 dot
## 
## Compute the dot product of two interval vectors.  If @var{X} and @var{Y} are
## matrices, calculate the dot products along the first non-singleton
## dimension.  If the optional argument @var{DIM} is given, calculate the dot
## products along this dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## dot ([infsup(1), 2, 3], [infsup(2), 3, 4])
##   @result{} [20]
## @end group
## @end example
## @seealso{plus, sum, times, sumabs, sumsquare}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function [result, isexact] = dot (x, y, dim)

if (nargin < 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

assert ((isvector (x.inf) && isvector (y.inf) && ...
            numel (x.inf) == numel (y.inf)) || ...
        size (x.inf) == size (y.inf), "dot: sizes of X and Y must match");

if (nargin < 3)
    ## Try to find non-singleton dimension
    dim = find (size (x.inf) > 1, 1);
    if (isempty (dim))
        dim = 1;
    endif
endif

if (dim == 1)
    resultsize = [1, size(x.inf, 2)];
elseif (dim == 2)
    resultsize = [size(x.inf, 1), 1];
else
    error ("dot: DIM must be a valid dimension")
endif

isexact = true (resultsize);
doublel = doubleu = zeros (resultsize);

for n = 1 : numel (isexact)
    ## Initialize accumulators
    l.e = int64 (0);
    l.m = zeros (1, 0, "int8");
    l.unbound = false ();
    u.e = int64 (0);
    u.m = zeros (1, 0, "int8");
    u.unbound = false ();
    empty = false ();
    
    for i = 1 : size (x.inf, dim)
        if (isvector (x.inf))
            x_inf = x.inf (i);
            x_sup = x.sup (i);
            y_inf = y.inf (i);
            y_sup = y.sup (i);
        elseif (dim == 1)
            x_inf = x.inf (i, n);
            x_sup = x.sup (i, n);
            y_inf = y.inf (i, n);
            y_sup = y.sup (i, n);
        else
            x_inf = x.inf (n, i);
            x_sup = x.sup (n, i);
            y_inf = y.inf (n, i);
            y_sup = y.sup (n, i);
        endif
    
        if (x_inf == inf || y_inf == inf)
            empty = true;
            break
        endif
        
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
    
    if (empty)
        doublel (n) = inf;
        doubleu (n) = -inf;
        isexact (n) = true ();
    else
        if (l.unbound)
            doublel (n) = -inf;
        else
            [doublel(n), isexact(n)] = accu2double (l, -inf);
        endif
        
        if (u.unbound)
            doubleu (n) = inf;
        else
            [doubleu(n), upperisexact] = accu2double (u, inf);
            isexact (n) = and (isexact (n), upperisexact);
        endif
    endif
endfor

result = infsup (doublel, doubleu);

endfunction