## Copyright 2008 Jiří Rohn
## Copyright 2016-2017 Oliver Heimlich
##
## This program is derived from verlinineqnn in VERSOFT, published on
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
## @deftypefun {[@var{x}, @var{y}] =} verlinineqnn (@var{A}, @var{b})
## Verified nonnegative solution of a system of linear inequalities.
##
## For a rectangular real matrix @var{A} and a matching real vector @var{b},
## this function either computes a verified solution of the system of linear
## inequalities
## @display
## @var{A} * @var{x} @leq{} b, @*
##           @var{x} @geq{} 0,
## @end display
## or verifies nonexistence of a solution, or yields no verified result.
##
## Possible outputs:
## @itemize @bullet
## @item
## Either @var{x} is a real vector verified to satisfy both inequalities and
## @var{y} is a vector of NaN's,
##
## @item
## or @var{y} is a real vector verified to satisfy
## @display
## @var{A}' * @var{y} @geq{} 0, @*
##            @var{y} @geq{} 0, @*
## @var{b}' * @var{y} @leq{} -1
## @end display
## (which by Farka's lemma implies nonexistence of a solution to the original
## inequalities), and @var{x} is a vector of NaN's,
##
## @item
## or both @var{x} and @var{y} are NaN's. In this case no verified result could
## be found.
## @end itemize
##
## This work was supported by the Czech Republic National Research Program
## “Information Society”, project 1ET400300415.
##
## @seealso{linprog}
## @end deftypefun

## Author: Jiří Rohn
## Keywords: interval
## Created: 2008-01-05

function [x, y] = verlinineqnn (A, b)

  if (nargin ~= 2)
    print_usage ();
    return
  endif

  b = b(:);
  [m, n] = size (A);

  if (m ~= length(b) || ~isreal (A) || ~isreal (b))
    error ("verlinineqnn: Parameters must be real and of matching size");
  endif

  if (~issparse (A))
    A = sparse (A);
  endif
  x = verlinineqnninner (A, b);
  if (~isnan (x(1)) || nargout < 2)
    y = nan (m, 1);
    return
  endif

  Ao = [-A'; -speye(m, m); b'];
  bo = [zeros(1, n + m), -1]';
  y = verlinineqnninner (Ao, bo);
endfunction


function x = verlinineqnninner (A, b)
  ## inner subroutine of verlinineqnn
  ## finds a verified solution to A*x<=b, x>=0, or yields a vector of NaN's
  ## additive and multiplicative perturbation used

  [m, n] = size (A);
  ep = max (1e-10, max ([m n 100]) * max ([norm(A, inf) norm(b, inf)]) * eps);
  e = ones (n, 1);
  Ao = [A; -speye(n, n)];
  bo = [b' zeros(n, 1)']'; # Ao*x<=bo is equivalent to A*x<=b, x>=0

                                # additive perturbation
  bo = bo - ep .* ones (m + n, 1);
  x = lpprocedure (e, Ao, bo); # solves min e'*x subject to Ao*x<=bo

  if (not (any (isnan (x)(:))))
    left = A * infsup (x); # interval quantity
    if (all (left.sup <= b) && all (x >= 0))
                                # verified solution
      return
    endif
  endif

                                # multiplicative perturbation
  bo = bo - ep .* abs (bo) - ep .* (bo == 0);
  x = lpprocedure (e, Ao, bo); # solves min e'*x subject to Ao*x<=bo

  if (not (any (isnan (x)(:))))
    left = A * infsup (x); # interval quantity
    if (all (left.sup <= b) && all (x >= 0))
                                # verified solution
      return
    endif
  endif

                                # no verified solution
  x = nan (n, 1);
endfunction


function x = lpprocedure (c, A, b)
  ## solves linear programming problem min c'*x subject to A*x<=b
  ## x should be always assigned (unverified optimal solution, or something else;
  ## the result is checked afterwards)
  ## placed separately so that a different linear programming procedure might
  ## also be used

  persistent GLP_MSG_OFF = 0;

  [m, n] = size (A);
  x = glpk (c, A, b, ...
            [], [], ... # 0 <= x <= inf
            repmat ("U", 1, m), ... # inequality constraint with an upper bound b
            repmat ("C", 1, n), ... # continuous variable x
            1, ... # minimization
            struct ("msglev", GLP_MSG_OFF));

endfunction

%!test
%! A = [-2, -3; -2, -1];
%! b = [-1500; -1000];
%! [x, y] = verlinineqnn (A, b);
%! assert (x, [375; 250], 1e-9);
%! assert (all (x >= [375; 250]));
%! assert (isnan (y));

%!test
%! A = [1, 2; 3, 4];
%! b = [-1; 0];
%! [x, y] = verlinineqnn (A, b);
%! assert (y, [1; 0], 1e-9);
%! assert (all (y >= [1; 0]));
%! assert (isnan (x));

%!test
%! A = [1, 2; 3, 4];
%! b = [1; 1];
%! [x, y] = verlinineqnn (A, b);
%! assert (x, [0; 0]);
%! assert (isnan (y));
