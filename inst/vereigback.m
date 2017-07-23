## Copyright 2008 Jiří Rohn
## Copyright 2016 Oliver Heimlich
##
## This program is derived from vereigback in VERSOFT, published on
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
## @deftypefun {[@var{lambda}, @var{X}, @var{ep}] =} vereigback (@var{A})
## Verified backward error analysis of eigenpairs.
##
## For a square complex (or real) matrix @var{A}, this function computes a
## vector of eigenvalues @var{lambda} and a matrix of eigenvectors @var{X}
## in the usual Octave way
## @display
## @code{[X, L] = eig (A); lambda = diag (L);}
## @end display
## and additionally a vector @var{ep} with the following property: for each
## @var{i} there exists a matrix, say @var{A}[@var{i}], verified to satisfy
## @code{max (max (abs (A - A[i]))) <= ep(i)} such that
## @code{(lambda(i), X(:, i))} is verified to be an @emph{exact} eigenpair
## of @var{A}[@var{i}].  If @var{A}, @code{lambda(i)}, and @code{X(:, i)} are
## real then @var{A}[@var{i}] can be taken real, otherwise it is complex in
## general. The maximal value of @code{ep(i)} is usually very small (of order
## 1e-013 to 1e-016), which shows that Octave computes eigenvalues and
## eigenvectors with great accuracy.
##
## Based on the inequality (3.13) in J. Rohn, A Handbook of Results on Interval
## Linear Problems, posted at @url{http://www.cs.cas.cz/~rohn}, which also
## holds for complex eigenpairs (unpublished).
##
## This work was supported by the Czech Republic National Research
## Program “Information Society”, project 1ET400300415.
## @seealso{eig}
## @end deftypefun

## Author: Jiří Rohn
## Keywords: interval
## Created: 2008

function [lambda, X, ep] = vereigback (A)

  warning ("on", "vereigback:complex", "local")
  if (nargin ~= 1)
    print_usage ();
    return
  endif

  [m, n] = size (A);
  [X, L] = eig (A); # A*X=X*L
  lambda = diag (L);

  I = eye (n);
  ep = inf (n, 1);
  if (nargout > 2)
    for i = 1 : n
      ll = lambda (i);
      xx = X(:, i);
      if (~isreal (ll) || ~isreal (xx))
        warning ("vereigback:complex", ...
                 "vereigback: complex eigenvalues / eigenvectors not supported")
        ## issue warning only once per function call
        warning ("off", "vereigback:complex", "local")
      endif
      ll = infsup (ll);
      xx = infsup (xx);
      epi = norm ((A - ll .* I) * xx, "inf") ./ norm (xx, 1); # main formula
      ep(i) = epi.sup;
    end
  endif

endfunction

%!test
%! [lambda, X, ep] = vereigback (eye (2));
%! assert (lambda, [1; 1]);
%! assert (X, eye (2));
%! assert (ep, zeros (2, 1));

%!test
%! [lambda, X, ep] = vereigback ([2 1; 1 2]);
%! assert (lambda, [1; 3]);
%! assert (X, [-1 1; 1 1] ./ sqrt (2), eps);
%! assert (ep, zeros (2, 1));

%!test
%! [lambda, X, ep] = vereigback ([2 0 0; 0 3 4; 0 4 9]);
%! assert (lambda, [1; 2; 11]);
%! assert (ep, zeros (3, 1));

%!test
%! [lambda, X, ep] = vereigback ([1 2 3; 0 1 2; 1 1 1]);
%! assert (max (ep) < 1e-14);
