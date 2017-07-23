## Copyright 2007 Jiří Rohn
## Copyright 2016 Oliver Heimlich
##
## This program is derived from verlinprog in VERSOFT, published on
## 2016-07-26, which is distributed under the terms of the Expat license,
## a.k.a. the MIT license.  Original Author is Jiří Rohn.  Migration to Octave
## code has been performed by Oliver Heimlich.
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
## @deftypefun {[@var{flag}, @var{x}, @var{y}, @var{h}] =} verlinprog (@var{A}, @var{b}, @var{c})
## Verified linear programming.
##
## For a real matrix @var{A} (full or sparse) and matching real vectors
## @var{b}, @var{c}, this function either computes verified optimal solution
## @var{x}, verified dual optimal solution @var{y} and verified optimal value
## @var{h} of the linear programming problem
## @display
## min @var{c}' * @var{x} subject to @var{A} * @var{x} = @var{b}, x @geq{} 0,
## @end display
## or verifies (in)feasibility, or verifies unboundedness, or yields no
## verified result. The respective outcome is always described verbally in the
## variable @var{flag}.
##
## Possible values of @var{flag}:
## @table @option
## @item verified optimum
## @var{x} is verified to enclose a primal optimal solution,
## @var{y} is verified to enclose a dual optimal solution,
## @var{h} is verified to enclose the optimal value,
##
## @item verified unbounded
## @var{x} is verified to enclose a primal feasible solution @var{xo}, and
## @var{y} is verified to enclose a vector @var{yo} such that the objective
## tends to -Inf along the feasible half-line
## @{@var{xo} + @var{t} * @var{yo} | @var{t} @geq{} 0@},
## @var{h} is empty,
##
## @item verified feasible
## @var{x} is verified to enclose a primal feasible solution
## (neither optimality nor unboundedness could be verified),
## @var{y}, @var{h} are empty,
##
## @item verified infeasible
## @var{y} is verified to enclose a Farkas vector @var{yo} satisfying
## @var{A}' * @var{yo} @geq{} 0, @var{b}' * @var{yo} < 0
## (whose existence proves primal infeasibility),
## @var{x}, @var{h} are empty,
##
## @item no verified result
## @var{x}, @var{y}, and @var{h} are empty (no verified result could be found).
## @end table
##
## Complexity: The algorithm solves at most four linear programming problems
## (independently of the size of the original problem) and uses a verification
## procedure which runs approximately in O(@var{m}³) time, where
## @var{m} = rows (@var{A}).
##
## This work was supported by the Czech Republic National Research
## Program “Information Society”, project 1ET400300415.
## @seealso{linprog}
## @end deftypefun

## Author: Jiří Rohn
## Keywords: interval
## Created: 2007

function [flag, x, y, h] = verlinprog (A, b, c)

  if (nargin ~= 3)
    print_usage ();
    return
  endif

  b = b(:); c = c(:);
  [m, n] = size(A);
  p = length (b); q = length (c);

  flag = "no verified result";
  x = repmat (infsup, n, 1);
  y = repmat (infsup, m, 1);
  h = infsup;

  if (~(m == p && n == q) || (m > n))
    error ("verlinprog: sizes do not match");
  endif
  if (~isreal (A) || ~isreal (b) || ~isreal (c))
    error("verlinprog: data not real");
  endif
  if issparse (b)
    b = full (b);
  end
  if issparse (c)
    c = full (c);
  end

                                # verifying infeasibility
  yi = verinfeas (A, b);
  if (~isempty(yi(1))) # verified Farkas vector found
    y = yi;
    flag = "verified infeasible";
    return
  endif

                                # verifying feasibility
  xf = veropt (A, b, ones (n, 1));
  if (isempty (xf(1))) # verified feasible solution not found
    flag = "no verified result";
    return
  endif

                                # verifying unboundedness
  yu = verunbound (A, c);
  if (~isempty (yu(1))) # verified descent direction found
    x = xf;
    y = yu;
    flag = "verified unbounded";
    return
  endif

                                # verifying optimality
  [xo, B, N] = veropt (A, b, c);
  if (isempty (xo(1))) % verified feasible primal solution with basis B not found
    x = xf; # previous feasible solution outputted
    flag = "verified feasible";
    return
  endif

  AB = A(:, B);
  if (issparse (AB))
    AB = full (AB); # only the square submatrix taken full
  endif
  yB = mldivide (infsup (AB'), infsup (c(B)));
  if (isempty (yB(1))) # verified feasible dual solution not found
    x = xo; # candidate for optimum outputted as feasible solution
    flag = "verified feasible";
    return
  endif

  c = infsup (c);
  A = infsup (A);
  crit = c' - yB' * A; # criterial row (dual feasibility)
  crit = crit(N);      # nonbasic part of it
  if (~all (crit.inf >= 0)) # verified feasible dual solution not found
    x = xo; % candidate for optimum outputted as feasible solution
    flag = "verified feasible";
    return
  endif

# verified quantities     # verified primal and dual feasible solutions found
  x = xo;                   # x is a verified primal optimal solution
  y = yB;                   # y is a verified dual optimal solution
  if (nargout >= 3)
    h1 = c' * x;
    h2 = b' * y;
    h = intersect (h1, h2);   # h is a verified optimal value (duality theorem)
    if (isempty (h))
      h = h1;
    end
  endif
  flag = "verified optimum";
endfunction


function [x, B, N] = veropt (A, b, c)
  ## B is the "basis index set" of an optimal solution of the LP problem
  ## min c'*x  subject to  A*x=b, x>=0,
  ## x is a verified basic feasible solution with this basis
  ## N is the set of nonbasic indices

  persistent GLP_MSG_OFF = 0;
  [m, n] = size (A);
  x = repmat(infsup, n, 1);
  B = nan (m, 1);
  N = nan (n, 1);

  [xopt, ~, exitflag] = glpk (c, A, b, ...
                              [], [], ... # 0 <= x <= inf
                              repmat ("S", 1, m), ... # equality constraints Ax = b
                              repmat ("C", 1, n), ... # continuous variable x
                              1, ... # minimization
                              struct ("msglev", GLP_MSG_OFF));

  if (exitflag ~= 0)
    return
  endif

  [xx, J] = sort (xopt);
  B = J(n - m + 1 : n); # B is set of "basic" indices,
  N = J(1 : n - m);     # N of "nonbasic" ones

  AB = A(:, B);
  if (issparse (AB))
    AB = full (AB); # only the square submatrix taken full (because of mldivide)
  endif
  xB = mldivide (infsup (AB), infsup (b));
  if (isempty (xB(1)) || ~all (xB.inf >= 0))
                               # verified "optimal" solution not found
    return
  endif

                                # verified "optimal" solution found
  x = infsup (zeros (n, 1));
  x(B) = xB;
endfunction


function y = verinfeas (A, b)
  # y verified to enclose a Farkas vector yo (i.e., satisfying A'*yo>=0, b'*yo<0)
  # its existence implies infeasibility of A*x=b

  [m, n] = size (A);
  y = repmat(infsup, m, 1);
  ep = max (1e-08, max ([m n 100]) * max ([norm(A, inf) norm(b, inf)]) * eps);
  Afv = [A' -A'    -eye(n) zeros(n,1);    # Afv is (n+1)x(2*m+n+1)
         b' -b' zeros(1,n)         1];
  bfv = [zeros(n, 1)' -1]';               # bfv is (n+1)x1

        # perturbation to compensate roundoff errors (so that A'*y>=0)
  bfv = bfv + ep * [ones(1, n) -1]';
  yf = veropt (Afv, bfv, ones (2 * m + n + 1, 1)); % system: A'*y>=0, b'*y<=-1, y written as y=y1-y2
  if (~isempty (yf(1)))
    yf = mid (yf);
    y1 = yf(1 : m);
    y2 = yf(m + 1 : 2 * m);
    yf = y1 - y2;                      # would-be Farkas vector
    A = infsup (A);
    b = infsup (b);
    yf = infsup (yf);                  # (i.e., should satisfy A'*y>=0, b'*y<0)
    alpha = A' * yf;
    beta = b' * yf;
    if (all (alpha.inf >= 0)) && (beta.sup < 0)
                                # infeasibility verified
      y=yf; # Farkas vector outputted
    endif
  endif
endfunction


function y = verunbound (A, c)
  # y verified to enclose a vector yo satisfying A*yo=0, yo>=0, c'*yo<=-1
  # under feasibility its existence implies unboundedness

  [m, n] = size (A);
  y = repmat (infsup, n, 1);
  Aunb = [A zeros(m, 1);                       # Aunb is (m+1)x(n+1)
          c'         1];
  bunb = [zeros(1, m) -1]';                    # bunb is (m+1)x1
  yunb = veropt (Aunb, bunb, ones (n + 1, 1)); # yunb is (n+1)x1
  if (~isempty (yunb(1)))
                                # y satisfies A*y=0, y>=0, c'*y=-1
    y = yunb(1:n);
    return
  endif
endfunction

%!test
%! A = [-2, -3; -2, -1];
%! b = [-1500, -1000];
%! c = [1; 1];
%! [flag, x, y, h] = verlinprog (A, b, c);
%! assert (flag, "verified optimum");
%! assert (ismember ([375; 250], x));
%! assert (wid (x) < 1e-12);
%! assert (ismember ([-0.25; -0.25], y));
%! assert (wid (y) < 1e-16);
%! assert (ismember (625, h));
%! assert (wid (h) < 1e-12);
