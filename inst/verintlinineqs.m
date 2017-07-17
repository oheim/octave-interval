## Copyright 2007-2008 Jiří Rohn
## Copyright 2016 Oliver Heimlich
##
## This program is derived from verintlinineqs in VERSOFT, published on
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
## @deftypefun {[@var{x}, @var{As}] =} verintlinineqs (@var{A}, @var{b})
## Verified strong solution of interval linear inequalities.
##
## For a rectangular interval matrix @var{A} and a matching interval
## vector @var{b}, this function either computes a strong solution @var{x} to
## @display
## @var{A} * @var{x} @leq{} b
## @end display
## (i. e., a real vector @var{x} verified to satisfy
## @var{Ao} * @var{x} @leq{} @var{bo} for each @var{Ao} in @var{A} and @var{bo}
## in @var{b}), or verifies nonexistence of such a solution, or yields no
## verified result:
##
## @table @asis
## @item ~isnan (@var{x})
## @var{x} is a verified strong solution of @var{A} * @var{x} @leq{} @var{b},
## and @var{As} is an interval matrix of empty intervals,
##
## @item ~isempty (@var{As})
## @var{As} is a very right (“almost thin”) interval matrix verified to contain
## a real matrix @var{Ao} such that the system
## @var{Ao} * @var{x} @leq{} @var{b}.inf has no solution (which proves that no
## strong solution exists), and @var{x} is a vector of NaNs,
##
## @item otherwise
## no verified output.
## @end table
##
## A theoretical result [1] asserts that if each system
## @var{Ao} * @var{x} @leq{} @var{bo}, where @var{Ao} in @var{A} and @var{bo}
## in @var{b}, has a solution (depending generally on @var{Ao} and @var{bo}),
## then there exists a vector @var{x} satisfying
## @var{Ao} * @var{x} @leq{} @var{bo} for @emph{each} @var{Ao} in @var{A} and
## @var{bo} in @var{b}.  Such a vector @var{x} is called a strong solution of
## the system @var{A} * @var{x} @leq{} @var{b}.
##
## [1] J. Rohn and J. Kreslova, Linear Interval Inequalities, LAMA 38 (1994),
## 79–82.
##
## Based on Section 2.13 in M. Fiedler, J. Nedoma, J. Ramik, J. Rohn and
## K. Zimmermann, Linear Optimization Problems with Inexact Data,
## Springer-Verlag, New York 2006.
##
## This work was supported by the Czech Republic National Research Program
## “Information Society”, project 1ET400300415.
##
## @seealso{}
## @end deftypefun

## Author: Jiří Rohn
## Keywords: interval
## Created: 2007-02-22

function [x, As] = verintlinineqs (A, b)

  if (nargin ~= 2)
    print_usage ();
    return
  endif

  b = vec (b);
  [m, n] = size (A);
  x = nan (n, 1);
  As = repmat (infsup (), m, n);

  if (m ~= length (b))
    error ("verintlinineqs: nonconformant arguments")
  endif

  if (not (isa (A, "infsup"))) # allows for real input
    A = infsup (A);
  endif

  if (not (isa (b, "infsup")))
    b = infsup (b);
  endif

  ## the bounds
  Al = inf (A);
  Au = sup (A);
  bl = inf (b);

  ## matrix of the system; see Fiedler et al., (2.89)
  Ao = [Au -Al];

  ## finds verified nonnegative solution of Ao*x<=bl
  [xx, y] = verlinineqnn (Ao, bl);

  if (not (isnan (xx(1)))) # solution found
    xxi = infsup (xx);
    xxi = xxi(1:n) - xxi(n+1:2*n); # interval vector of the original size

    ## noninterval vectors; candidates for strong solution
    X = [xx(1:n)-xx(n+1:2*n) xxi.inf xxi.mid xxi.sup];

    [Ac, Delta] = rad (A);
    [bc, delta] = rad (b);

    for x1 = X
      left = Ac * infsup (x1) - bc;
      right = -Delta * infsup (abs(x1)) - delta;

      if (all (left.sup <= right.inf))
        ## Fiedler et al., (2.94); strong solution found
        x = x1; # verified strong solution
        return
      endif
    endfor

    ## no result
    return
  end

  if (not (isnan (y(1)))) # Ao*x<=bl verified not to have a nonnegative solution
    As = vernull(A', y); # Fiedler et al., proof of Thm. 2.23
    if (not (isempty (As(1,1))))
      As = As'; # Ao*x<=bl unsolvable for some Ao in As which is a part of A
      return
    endif

    ## no result
    return
  end

  ## no result
endfunction

function As = vernull (A, x)
  #    VERNULL    Verified matrix in A having x as a null vector.
  #
  #    ~isempty(As(1,1)): As is a tight interval matrix verified to be a part of A
  #                       and to contain a thin matrix Ao having x as a null vector
  #                       (i.e., Ao*x=0),
  #
  #     isempty(As(1,1)): no result.
  #

  [m, n] = size (A);
  p = length (x);

  As = repmat (infsup (), m, n);
  assert (n == p);
  assert (nargin == 2);
  assert (isa (A, "infsup"));
  assert (not (isa (x, "infsup")));
  assert (all (not (isnan (x))));

  z = sgn (x);
  xi = infsup (x);

  [Ac, Delta] = rad (A);
  oeprl = abs (Ac * xi);                      % Oettli-Prager inequality, left  side
  oeprr = Delta * abs (xi);                   % Oettli-Prager inequality, right side
  if (all (oeprl.sup <= oeprr.inf))           % Oettli-Prager inequality satisfied, x verified null vector of A
    y = (Ac * xi) ./ oeprr;
    y(isempty (y)) = 1;                     % case of both numerator and denominator being zero
    As = Ac - (diag (y) * Delta) * diag(z); % construction of As ...
    As = intersect (As, A);                 % ... in A
    if (not (any (any (isempty(As)))))      % intersection nowhere empty
      return                              % with output As
    else
      As = repmat (infsup (), m, n);
      return                              % with As of [Empty]'s, but x still verified null vector of A
    endif
  endif

endfunction

function z = sgn (x)
  # signum of x for real

  n = length (x);
  z = ones (n, 1);
  z(x < 0) = -1;
endfunction

%!test
%! A = [-2, -3; -2, -1];
%! b = [-1500; -1000];
%! [x, As] = verintlinineqs (A, b);
%! assert (x, [375; 250], 1e-9);
%! assert (all (x >= [375; 250]));
%! assert (all (all (isempty (As))));
