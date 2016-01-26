## Copyright 2016 Oliver Heimlich
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
## @documentencoding UTF-8
## @defmethod {@@infsup} norm (@var{A}, @var{P})
## @defmethodx {@@infsup} norm (@var{A}, @var{P}, @var{OPT})
## 
## Compute the p-norm of the matrix @var{A}.
##
## If @var{A} is a matrix:
## @table @asis
## @item @var{P} = 1
## 1-norm, the largest column sum of the absolute values of @var{A}.
## @item @var{P} = inf
## Infinity norm, the largest row sum of the absolute values of @var{A}.
## @item @var{P} = "fro"
## Frobenius norm of @var{A}, @code{sqrt (sum (diag (A' * A)))}.
## @end table
##
## If @var{A} is a vector or a scalar:
## @table @asis
## @item @var{P} = inf
## @code{max (abs (A))}.
## @item @var{P} = -inf
## @code{min (abs (A))}.
## @item @var{P} = "fro"
## Frobenius norm of @var{A}, @code{sqrt (sumsq (abs (A)))}.
## @item @var{P} = 0
## Hamming norm - the number of nonzero elements.
## @item other @var{P}, @code{@var{P} > 1}
## p-norm of @var{A}, @code{(sum (abs (A) .^ P)) ^ (1/P)}.
## @item other @var{P}, @code{@var{P} < 1}
## p-pseudonorm defined as above.
## @end table
##
## If @var{OPT} is the value "rows", treat each row as a vector and compute its
## norm.  The result returned as a column vector.  Similarly, if @var{OPT} is
## "columns" or "cols" then compute the norms of each column and return a row
## vector.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## norm (infsup (magic (3)), "fro")
##   @result{} ans ⊂ [16.881, 16.882]
## @end group
## @group
## norm (infsup (magic (3)), 1, "cols")
##   @result{} ans = 1×3 interval vector
##
##        [15]   [15]   [15]
##
## @end group
## @end example
## @seealso{@@infsup/abs, @@infsup/max}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2016-01-26

function result = norm (A, p, opt)

if (nargin > 3 || not (isa (A, "infsup")))
    print_usage ();
    return
endif

if (isa (A, "infsupdec"))
    if (isnai (A))
        result = A;
        return
    endif
endif

if (nargin < 2)
    p = 2;
    opt = "";
elseif (nargin < 3)
    opt = "";
endif

switch (opt)
    case "rows"
        dim = 2;
    case {"columns", "cols"}
        dim = 1;
    case ""
        if (isvector (A.inf))
            ## Try to find non-singleton dimension
            dim = find (size (A.inf) > 1, 1);
            if (isempty (dim))
                dim = 1;
            endif
        else
            dim = [];
        endif
endswitch

if (isempty (dim))
    ## Matrix norm
    switch (p)
        case 1
            result = max (sum (abs (A), 1));
        case inf
            result = max (sum (abs (A), 2));
        case "fro"
            result = sqrt (sumsq (vec (A)));
        otherwise
            error ("norm: Particular matrix norm is not yet supported")
    endswitch
else
    ## Vector norm
    switch (p)
        case inf
            result = max (abs (A), [], dim);
        case -inf
            result = min (abs (A), [], dim);
        case "fro"
            result = sqrt (sumsq (abs (A), dim));
        case 0
            result = infsup (sum (not (ismember (0, A)), dim), ...
                             sum (0 != A, dim)) - ...
                             sum (isempty (A), dim);
        otherwise
            warning ("off", "interval:ImplicitPromote", "local");
            result = (sum (abs (A) .^ p, dim)) .^ (1 ./ infsup (p));
    endswitch
endif

endfunction

%!xtest
%! A = infsup ("0 [Empty] [0, 1] 1");
%! assert (isequal (norm (A, 0, "cols"), infsup ("0 0 [0, 1] 1")));
