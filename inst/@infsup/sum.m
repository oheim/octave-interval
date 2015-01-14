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
## @deftypefn {Interval Function} {} sum (@var{X})
## @deftypefnx {Interval Function} {} sum (@var{X}, @var{DIM})
## 
## Sum of elements along dimension @var{DIM}.  If @var{DIM} is omitted, it
## defaults to the first non-singleton dimension.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sum ([infsup(1), pow2(-1074), -1])
##   @result{} [4e-324, 5e-324]
## infsup (1) + pow2 (-1074) - 1
##   @result{} [0, 2.2204460492503131e-16]
## @end group
## @end example
## @seealso{plus}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-26

function result = sum (x, dim)

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
    error ("sum: DIM must be a valid dimension")
endif

l = u = zeros (resultsize);

for n = 1 : numel (l)
    idx.type = "()";
    idx.subs = cell (1, 2);
    idx.subs {dim} = ":";
    idx.subs {3 - dim} = n;

    ## Select current vector in matrix
    if (size (x.inf, 3 - dim) == 1)
        vector.x = x;
    else
        vector.x = subsref (x, idx);
    endif
    
    if (max (isempty (vector.x)))
        ## One of the intervals is empty
        l (n) = inf;
        u (n) = -inf;
    else
        l (n) = mpfr_vector_sum_d (-inf, x.inf);
        u (n) = mpfr_vector_sum_d (+inf, x.sup);
    endif
endfor

result = infsup (l, u);

endfunction
