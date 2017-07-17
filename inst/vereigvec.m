## Copyright 2007 Jiří Rohn
## Copyright 2016 Oliver Heimlich
##
## This program is derived from vereigvec in VERSOFT, published on
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
## @deftypefun {[@var{evc}, @var{lambda}, @var{As}] =} vereigvec (@var{A}, @var{x})
## Verified real eigenvector of an interval matrix.
##
## For a square interval matrix @var{A} and a @emph{real} vector @var{x}, this
## function verifies @var{x} to be an eigenvector of some matrix in @var{A}, or
## not to be an eigenvector of any matrix in @var{A}, or yields no verified
## result (unfortunately, complex eigenvectors cannot be handled yet):
##
## @table @asis
## @item @var{evc} = 1
## @var{x} is verified to be an eigenvector of some matrix in @var{A},
## @var{lambda} is an interval number such that for each
## @var{lambda0} ∈ @var{lambda}, @var{A} is verified to contain a matrix having
## (@var{lamda0}, @var{x}) as an eigenpair,
## @var{As} is a very tight interval matrix verified to contain
## a matrix having (mid (@var{lambda}), @var{x}) as an eigenpair,
##
## @item @var{evc} = 0
## @var{x} is verified not to be an eigenvector of any matrix in @var{A},
## @var{lambda} and @var{As} consist of empty intervals,
##
## @item @var{evc} = -1
## no verified result (data may be wrong).
## @end table
##
## Based on the section “Real eigenvectors” in
## J. Rohn, A handbook of results on interval linear problems,
## posted at @url{http://www.cs.cas.cz/~rohn}.
##
## This work was supported by the Czech Republic National Research
## Program “Information Society”, project 1ET400300415.
##
## @seealso{eig}
## @end deftypefun

## Author: Jiří Rohn
## Keywords: interval
## Created: 2007

function [evc, lambda, As] = vereigvec (A, x)

  if (nargin ~= 2)
    print_usage ();
    return
  endif

  x = x(:);
  p = length(x);
  [m, n] = size (A);

  if (m ~= n)
    error ("vereigvec: matrix is not square");
  elseif (n ~= p)
    error ("vereigvec: sizes do not match");
  elseif (~isreal (x) || isequal (x, zeros (p, 1)))
    error ("vereigvec: wrong data");
  endif

  if (~isa (A, "infsup"))
    if (~isreal (A))
      error ("vereigvec: wrong data");
    endif
    A = infsup (A); # allows for real input
  endif

  ## checking the basic inequality
  [ac, Delta] = rad (A);
  z = sgn (x);
  x1 = infsup (x); # x double, x1 intval
  Tz = infsup (diag (z));
  left = Tz * (ac - Tz * Delta * Tz) * x1 * x1' * Tz; # left-hand side of the inequality
  right = Tz * x1 * x1' * (ac + Tz * Delta * Tz)' * Tz; # right-hand side of the inequality

  ## inequality verified not to be satisfied
  if (any ((right.sup < left.inf)(:)))
    ## verified not to be an eigenvector
    evc = 0;
    lambda = infsup ();
    As = repmat (infsup (), n, n);
    return
  endif

  ## inequality verified to be satisfied
  if (all (all (left.sup <= right.inf))) # verified to be an eigenvector; Rohn, SIMAX 1993, Thm. 4.1
    B = find (x ~= 0);
    denleft = (Tz * ac * Tz - Delta) * abs (x);
    denright = (Tz * ac * Tz + Delta) * abs (x);
    num = abs (x);
    denleft = denleft(B);
    denright = denright(B);
    num = num(B);
    left = denleft ./ num;     # left  ratio
    right = denright ./ num;   # right ratio
    lambdal = max (left.sup);  # verified lower bound of lambda
    lambdau = min (right.inf); # verified upper bound of lambda
    if (lambdal > lambdau)
      ## bounds contradict: no verified solution
      evc = -1;
      lambda = infsup ();
      As = repmat (infsup (), n, n);
      return
    endif

    lambda = infsup (lambdal, lambdau); # lambda
    lambdam = mid (lambda);             # midpoint of lambda

    ## finding a matrix with eigenpair (lambdam, x)
    A1 = A - lambdam .* eye (n);
    AAs = versingnull (A1, x); # enclosure of a singular matrix in A1 having x as a null vector
    if (isempty (AAs(1, 1)))
                        # no enclosure outputted: no verified solution
      evc = -1;
      lambda = infsup ();
      As = repmat (infsup (), n, n);
      return
    endif

    AAs = AAs + lambdam .* eye (n); # back to A
    if (subset (AAs, A)) # AAs part of A
      ## (lambdam, x) is an eigenpair of a matrix in As; Rohn, SIMAX 1993, proof of Thm. 4.1
      evc = 1;
      As=AAs;
      return
    endif

    ## AAs not a part of A: no verified result
    evc = -1;
    lambda = infsup ();
    As = repmat (infsup (), n, n);
    return
  endif

  ## no verified result
  evc = -1;
  lambda = infsup ();
  As = repmat (infsup (), n, n);
endfunction


function As = versingnull (A, x)
  ## VERSINGNULL    Verified singular matrix in A having x as a null vector.
  ##
  ## ~isempty (As(1, 1)): As is a tight interval matrix verified to be a part
  ##                      of A and to contain a singular matrix having x
  ##                      as a null vector
  ##  isempty (As(1, 1)): no result

  [m, n] = size (A);
  assert (m == n);
  z = sgn (x);
  xi = infsup (x);
  [Ac, Delta] = rad (A);
  oeprl = abs (Ac * xi);            # Oettli-Prager inequality, left  side
  oeprr = Delta * abs (xi);         # Oettli-Prager inequality, right side
  if (all (oeprl.sup <= oeprr.inf)) # Oettli-Prager inequality satisfied, singularity of A verified
    y = (Ac * xi) ./ oeprr;
    y(isempty (y)) = infsup (1, 1); # case of both numerator and denominator being zero
    As = Ac - (diag (y) * Delta) * diag (z); # construction of singular As ...
    As = intersect (As, A);                  # ... in A
    if (~any (any (isempty (As)))) # intersection nowhere empty
      return                     # with output As
    endif
    ## with As of [Empty]'s, but still verified singular (this fact not used here)
  endif
  As = repmat (infsup (), n, n);
endfunction


function z = sgn (x)
                                # signum of x for real

  n = length (x);
  z = ones (n, 1);
  z(x < 0) = -1;
endfunction

%!test
%! A = [1 0 0; 0 1 1; 0 0 1];
%! assert (vereigvec (A, [1; 0; 0]), 1);
%! assert (vereigvec (A, [0; 1; 0]), 1);
%! assert (vereigvec (A, [0; 0; 1]), 0);

%!test
%! A = magic (3);
%! [evc, lambda] = vereigvec (A, [1 1 1]);
%! assert (evc, 1);
%! assert (lambda == 15);
%! assert (vereigvec (A, [1; 0; 0]), 0);
%! assert (vereigvec (A, [0; 1; 0]), 0);
%! assert (vereigvec (A, [0; 0; 1]), 0);

%!test
%! A = magic (3) + infsup ("[-5, 5]");
%! [evc, lambda, As] = vereigvec (A, [1 0 0]);
%! assert (evc, 1);
%! assert (lambda == "[3, 13]");
%! assert (ismember ([8 1 6; 0 2 4; 0 5 -2], As));
%! assert (max (max (wid (As))) < 1e-14);
