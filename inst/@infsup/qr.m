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
## @deftypemethod {@@infsup} {[@var{Q}, @var{R}] =} qr (@var{A})
## @deftypemethodx {@@infsup} {[@var{Q}, @var{R}, @var{P}] =} qr (@var{A})
## Compute the QR decomposition of @var{A}.
##
## @var{A} will be a subset of @var{Q} * @var{R} with orthogonal matrix @var{Q}
## and triangular matrix @var{R}.
##
## The columns of @var{Q} are orthogonal unit vectors, that is, @code{Q' * Q}
## equals the identity.  @var{R} is an upper triangular matrix with positive
## diagonal elements.
##
## The result is returned in a permuted form, according to the optional return
## value @var{P}.
##
## Accuracy: The result is a valid enclosure.
## @seealso{@@infsup/lu, @@infsup/chol}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2016-06-26

function [Q, R, P] = qr (A)

  ## We use the Gram-Schmidt process, since Householder reflections would
  ## introduce a much larger overestimation for Q in most cases.

  n = length (A);
  Q = resize (A, n);
  R = zeros (n);
  P = eye (columns (A));

  warning ("off", "Octave:broadcast", "local");

  for i = 1 : n
    iColIdx = substruct ("()", {":", i});
    if (nargout >= 3 && i < columns (A))
      ## Swap columns of Q, choose the column with maximum norm as next pivot
      B = subsref (Q, substruct ("()", {":", i : n}));
      [~, j] = max (mig (sumsq (B, 1)));
      j += i - 1;
      if (j != i)
        swapIdx = 1 : n;
        swapIdx([i j]) = [j i];
        swap = @(X) subsref (X, substruct ("()", {":", swapIdx}));
        Q = swap (Q);
        R = swap (R);
        P = P(:, swapIdx(1 : columns (A)));
      endif
    endif
    iCol = subsref (Q, iColIdx);
    d = norm (iCol, 2);
    iCol = mulrev (d, iCol, "[-1, +1]");
    Q = subsasgn (Q, iColIdx, iCol);
    R = subsasgn (R, substruct ("()", {i, i}), d);

    if (i < n)
      otherColsIdx = substruct ("()", {":", (i + 1) : n});
      otherCols = subsref (Q, otherColsIdx);
      d = dot (otherCols, iCol, 1);
      otherCols -= d .* iCol;
      Q = subsasgn (Q, otherColsIdx, otherCols);
      R = subsasgn (R, substruct ("()", {i, (i + 1) : n}), d);
    endif
  endfor

  Q = resize (Q, rows (A));
  R = resize (R, size (A));
  P = inv (P);

endfunction

%!test
%! A = infsup ([1 2 3; 4 5 6]);
%! [Q, R] = qr (A);
%! assert (all (all (subset (A, Q * R))));
%! assert (all (all (subset (eye (length (Q)), Q' * Q))));
%! assert (max (max (wid (Q))) < 1e-14);
%!test
%! A = infsup ([1 2; 3 4; 5 6]);
%! [Q, R] = qr (A);
%! assert (all (all (subset (A, Q * R))));
%! assert (all (all (subset (eye (length (Q)), Q' * Q))));
%! assert (max (max (wid (Q (:, [1 2])))) < 1e-14);
%!test
%! A = infsup ([1 2 3; 4 9 6; 9 8 7]);
%! [Q, R] = qr (A);
%! assert (all (all (subset (A, Q * R))));
%! assert (all (all (subset (eye (length (Q)), Q' * Q))));
%! assert (max (max (wid (Q))) < 1e-13);
%!test
%! for n = 3 : 2 : 10
%!   A = infsup (magic (n));
%!   [Q, R] = qr (A);
%!   assert (all (all (subset (A, Q * R))));
%!   assert (all (all (subset (eye (length (Q)), Q' * Q))));
%!   assert (max (max (wid (Q))) < 1e-10);
%! endfor
%!test
%! A = infsup (magic (3)) + "[2, 2.2]";
%! [Q, R] = qr (A);
%! assert (all (all (subset (A, Q * R))));
%! assert (all (all (subset (eye (length (Q)), Q' * Q))));
%! assert (max (max (wid (Q))) < 1.5);

%!function result = is_permutation_matrix (P)
%! result = isequal (P, eye (length (P))) || ...
%!          isequal (typeinfo (P), "permutation matrix");
%!endfunction
%!test
%! A = infsup ([1 2 3; 4 5 6]);
%! [Q, R, P] = qr (A);
%! assert (all (all (subset (A, Q * R * P))));
%! assert (all (all (subset (eye (length (Q)), Q' * Q))));
%! assert (max (max (wid (Q))) < 1e-14);
%! assert (is_permutation_matrix (P));
%!test
%! A = infsup ([1 2; 3 4; 5 6]);
%! [Q, R, P] = qr (A);
%! assert (all (all (subset (A, Q * R * P))));
%! assert (all (all (subset (eye (length (Q)), Q' * Q))));
%! assert (max (max (wid (Q (:, [1 2])))) < 1e-14);
%! assert (is_permutation_matrix (P));
%!test
%! A = infsup ([1 2 3; 4 9 6; 9 8 7]);
%! [Q, R, P] = qr (A);
%! assert (all (all (subset (A, Q * R * P))));
%! assert (all (all (subset (eye (length (Q)), Q' * Q))));
%! assert (max (max (wid (Q))) < 1e-13);
%! assert (is_permutation_matrix (P));
%!test
%! for n = 3 : 2 : 10
%!   A = infsup (magic (n));
%!   [Q, R, P] = qr (A);
%!   assert (all (all (subset (A, Q * R * P))));
%!   assert (all (all (subset (eye (length (Q)), Q' * Q))));
%!   assert (max (max (wid (Q))) < 1e-10);
%!   assert (is_permutation_matrix (P));
%! endfor
%!test
%! A = infsup (magic (3)) + "[2, 2.2]";
%! [Q, R, P] = qr (A);
%! assert (all (all (subset (A, Q * R * P))));
%! assert (all (all (subset (eye (length (Q)), Q' * Q))));
%! assert (max (max (wid (Q))) < 1.5);
%! assert (is_permutation_matrix (P));
