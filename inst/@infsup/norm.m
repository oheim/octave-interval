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
## @defmethodx {@@infsup} norm (@var{A}, @var{P}, @var{Q})
## @defmethodx {@@infsup} norm (@var{A}, @var{P}, @var{OPT})
##
## Compute the p-norm (or p,q-norm) of the matrix @var{A}.
##
## If @var{A} is a matrix:
## @table @asis
## @item @var{P} = 1
## 1-norm, the largest column sum of the absolute values of @var{A}.
## @item @var{P} = inf
## Infinity norm, the largest row sum of the absolute values of @var{A}.
## @item @var{P} = "fro"
## Frobenius norm of @var{A}, @code{sqrt (sum (diag (@var{A}' * @var{A})))}.
## @end table
##
## If @var{A} is a vector or a scalar:
## @table @asis
## @item @var{P} = inf
## @code{max (abs (@var{A}))}.
## @item @var{P} = -inf
## @code{min (abs (@var{A}))}.
## @item @var{P} = "fro"
## Frobenius norm of @var{A}, @code{sqrt (sumsq (abs (A)))}.
## @item @var{P} = 0
## Hamming norm - the number of nonzero elements.
## @item other @var{P}, @code{@var{P} > 1}
## p-norm of @var{A}, @code{(sum (abs (@var{A}) .^ @var{P})) ^ (1/@var{P})}.
## @item other @var{P}, @code{@var{P} < 1}
## p-pseudonorm defined as above.
## @end table
##
## It @var{Q} is used, compute the subordinate matrix norm induced by the
## vector p-norm and vector q-norm. The subordinate p,q-norm is defined as the
## maximum of @code{norm (@var{A} * @var{x}, @var{Q})}, where @var{x} can be
## chosen such that @code{norm (@var{x}, @var{P}) = 1}. For @code{@var{P} = 1}
## and @code{@var{Q} = inf} this is the max norm,
## @code{max (max (abs (@var{A})))}.
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

  if (nargin < 2)
    p = 2;
    opt = "";
  elseif (nargin < 3)
    opt = "";
  endif

  if (strcmp (p, "inf"))
    p = inf;
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
    otherwise
      ## Subordinate p,q matrix norm
      q = opt;
      dim = [];
      if (strcmp (q, "inf"))
        q = inf;
      endif
      if (p == 1 && q == inf)
        ## Max norm
        result = max (max (abs (A)));
        return
      elseif (p == 1 && q == 1)
        ## 1-norm, computed below
      elseif (p == inf && q == inf)
        ## inf-norm, computed below
      elseif (p == inf && q == 1)
        ## inf,1-norm
        ## Computation via z' * A * y
        ## with y and z being vectors of -1 and 1 entries.

        ## Important papers by Jiří Rohn
        ##
        ## Computing the Norm || A ||_{inf,1} is NP-Hard
        ## Linear and Multilinear Algebra 47 (2000), 195-204.
        ## http://dx.doi.org/10.1080/03081080008818644
        ## http://uivtx.cs.cas.cz/~rohn/publist/norm.pdf
        ##
        ## R. Farhadsefat, J. Rohn and T. Lotfi,
        ## Norms of Interval Matrices.
        ## Technical Report No. 1122, Institute of Computer Science,
        ## Academy of Sciences of the Czech Republic, Prague 2011.
        ## http://www3.cs.cas.cz/ics/reports/v1122-11.pdf
        ## http://uivtx.cs.cas.cz/~rohn/publist/normlaa.pdf

        result = 0;
        ## Unfortunately this is NP-hard
        # 2^n different logical vectors of length n
        y = dec2bin ((1 : pow2 (columns (A)))' - 1) == '1';
                           # 2^m different logical vectors of length m
        z = dec2bin ((1 : pow2 (rows (A)))' - 1) == '1';
        for i = 1 : rows (y)
          idx = substruct ("()", {":", y(i, :)});
          B = subsasgn (A, idx, ...
                        uminus (subsref (A, idx)));
          for j = 1 : rows (z)
            idx = substruct ("()", {z(j, :), ":"});
            C = subsasgn (B, idx, ...
                          uminus (subsref (B, idx)));
            result = max (result, sum (vec (C)));
          endfor
        endfor
        return
      else
        error ("norm: Particular option or p,q-norm is not yet supported")
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
      case {"fro", 2}
        result = sqrt (sumsq (A, dim));
      case 0
        ## Hamming norm: the number of non-zero elements
        result = sum (subsasgn (subsasgn (subsasgn ...
                                            (A, ...
                                             substruct ...
                                               ("()", ...
                                                {ismember(0, A)}), ...
                                             "[0, 1]"), ...
                                          substruct ("()", {A == 0}), 0), ...
                                substruct ("()", {A > 0 | A < 0}), 1), ...
                      dim);
      otherwise
        warning ("off", "interval:ImplicitPromote", "local");
        result = (sum (abs (A) .^ p, dim)) .^ (1 ./ infsup (p));
    endswitch
  endif

endfunction

%!test
%! A = infsup ("0 [Empty] [0, 1] 1");
%! assert (isequal (norm (A, 0, "cols"), infsup ("0 [Empty] [0, 1] 1")));
%!assert (norm (infsup (magic (3)), inf, 1) == 45);
%!assert (norm (infsup (-magic (3), magic (3)), inf, 1) == "[0, 45]");
