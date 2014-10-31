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
## @deftypefn {Interval Function} {} sumsquare (@var{X})
## @deftypefnx {Interval Function} {} sumsquare (@var{X}, @var{DIM})
## @cindex IEEE1788 sumSquare
## 
## Sum of squares along dimension @var{DIM}.  If @var{DIM} is omitted,
## it defaults to the first non-singleton dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sumsquare ([infsup(1), pow2(-1074), -1])
##   @result{} [2, 2.0000000000000005]
## @end group
## @end example
## @seealso{plus, sum, sumabs, sqr}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function [result, isexact] = sumsquare (x)

if (nargin < 2)
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
    error ("sumsquare: DIM must be a valid dimension")
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
        if (dim == 1)
            x_inf = x.inf (i, n);
            x_sup = x.sup (i, n);
        else
            x_inf = x.inf (n, i);
            x_sup = x.sup (n, i);
        endif
    
        if (x_inf == inf)
            empty = true;
            break
        endif
        
        if (x_inf <= 0 && 0 <= x.sup)
            ## 0 in interval^2, nothing to do
        else
            m = min (abs (x_inf), abs(x_sup));
            l = accuaddproduct (l, m, m);
        endif
    
        m = max (abs (x_inf), abs (x_sup));
        if (isfinite (m))
            if (not (u.unbound))
                u = accuaddproduct (u, m, m);
            endif
        else
            u.unbound = true ();
        endif
    endfor
    
    if (empty)
        doublel (n) = inf;
        doubleu (n) = -inf;
        isexact (n) = true ();
    else
        if (l.unbound)
            doublel (n) = -inf
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