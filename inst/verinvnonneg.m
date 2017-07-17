## Copyright 2008 Jiří Rohn
## Copyright 2016 Oliver Heimlich
##
## This program is derived from verinvnonneg in VERSOFT, published on
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
## @deftypefun {[nonneg, As] =} verinvnonneg (@var{A})
## Verified nonnegative invertibility of an interval matrix.
##
## For a square interval (or real) matrix @var{A}, this function verifies
## inverse nonnegativity of @var{A}, or not-inverse-nonnegativity of @var{A},
## or yields no verified result:
##
## @table @asis
## @item @var{nonneg} = 1
## @var{A} verified inverse nonnegative,
##
## @item @var{nonneg} = 0
## @var{A} verified not to be inverse nonnegative; @var{As} is a matrix in
## @var{A} (always one of the two bounds) which is verified not to be inverse
## nonnegative,
##
## @item @var{nonneg = -1}
## no verified result.
## @end table
##
## Based on the result by Kuttler, Math. of Computation 1971; see also J. Rohn,
## A Handbook of Results on Interval Linear Problems, posted at
## @url{http://www.cs.cas.cz/~rohn}, Section 3.9.
##
## This work was supported by the Czech Republic National Research
## Program “Information Society”, project 1ET400300415.
##
## @seealso{inv}
## @end deftypefun

## Author: Jiří Rohn
## Keywords: interval
## Created: 2008

function [nonneg, As] = verinvnonneg (A)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  [m, n] = size (A);
  nonneg = -1;
  As = repmat (infsup, m, n);

  if (m ~= n)
    error ("verinvnonneg: matrix not square");
  endif

  if (~isa (A, "infsup"))
    A = infsup (A); # allows for real input
  endif

  if (any (isempty (A)(:)))
                                # matrix is empty interval: no inverse
    nonneg = 0;
    return
  endif

  Al = infsup (inf (A), max (-realmax, inf (A)));
  Bl = inv (Al);
  if (all (all (issingleton (A))))
    Au = Al;
    Bu = Bl;
  else
    Au = infsup (min (realmax, sup (A)), sup (A));
    Bu = inv (Au);
  endif

  if (any ((isempty (Bl) | isempty (Bu))(:)))
                                # empty inverse: no inverse exists
    nonneg = 0;
    return
  endif
  if (all (all (Bl.inf >= 0)) && all (all (Bu.inf >= 0)))
          # verified inverse nonnegative; Kuttler, Math. of Comp. 1971
    nonneg = 1;
    return
  endif
  if (any ((Bl.sup < 0)(:)))
    nonneg = 0;
    As=Al; # A.inf verified not inverse nonnegative
    return
  endif
  if (any ((Bu.sup < 0)(:)))
    nonneg = 0;
    As = Au; # A.sup verified not inverse nonnegative
    return
  end
endfunction

%!assert (verinvnonneg (eye (1)), 1)
%!assert (verinvnonneg (eye (2)), 1)
%!assert (verinvnonneg (eye (3)), 1)
%!assert (verinvnonneg (eye (4)), 1)
%!assert (verinvnonneg (eye (5)), 1)
%!assert (verinvnonneg (eye (6)), 1)
%!assert (verinvnonneg (eye (7)), 1)
%!assert (verinvnonneg (eye (8)), 1)
%!assert (verinvnonneg (zeros (1)), 0)
%!assert (verinvnonneg (zeros (2)), 0)
%!assert (verinvnonneg (zeros (3)), 0)
%!assert (verinvnonneg (zeros (4)), 0)
%!assert (verinvnonneg (zeros (5)), 0)
%!assert (verinvnonneg (zeros (6)), 0)
%!assert (verinvnonneg (zeros (7)), 0)
%!assert (verinvnonneg (zeros (8)), 0)
%!assert (verinvnonneg (magic (7)), 0)
%!assert (verinvnonneg (infsup (-inf, inf)), -1)
