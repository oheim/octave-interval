## Copyright 2008 Jiří Rohn
## Copyright 2016 Oliver Heimlich
##
## This program is derived from verchol in VERSOFT, published on
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
## @deftypemethod {@@infsup} {@var{R} = } chol (@var{A})
## @deftypemethodx {@@infsup} {[@var{R}, @var{P}] = } chol (@var{A})
## @deftypemethodx {@@infsup} {[@var{R}, @dots{}] = } chol (@dots{}, "upper")
## @deftypemethodx {@@infsup} {[@var{L}, @dots{}] = } chol (@dots{}, "lower")
## Compute the Cholesky factor, @var{R}, of the symmetric positive definite
## matrix @var{A}.
##
## The Cholsky factor is defined by
## @display
## @var{R}' * @var{R} = @var{A}.
## @end display
##
## Called using the @option{lower} flag, @function{chol} returns the lower
## triangular factorization such that
## @display
## @var{L} * @var{L}' = @var{A}.
## @end display
## @seealso{@@infsup/lu, @@infsup/qr}
## @end deftypefun

## Author: Jiří Rohn
## Keywords: interval
## Created: 2008-02-02

function [fact, P] = chol (A, option)

if (nargin > 2)
    print_usage ();
    return
elseif (nargin < 2)
    option = "upper";
endif

if (not (any (strcmp (option, {"upper", "lower"}))))
    print_usage ();
    return
endif

[m, n] = size (A);
if (m ~= n)
    error ("chol: matrix is not square");
endif

## Matrix is symmetric by definition, eliminate illegal values
A = intersect (A, A');
P = 0;

## columnwise computation of L done in frame of A
for k = 1 : n
    idx_diag = substruct ("()", {k, k});
    ## row vector # enables vectorized computation
    el = subsref (A, substruct ("()", {k, 1 : k - 1}));
    ## first main formula (diagonal entry)
    alpha = subsref (A, idx_diag) - el * el';
    if (inf (alpha) <= 0)
        if (sup (alpha) <= 0)
            ## each symmetric Ao in A verified not to be PD
            P = -alpha.sup;
            if (nargout < 2)
                error ("chol: matrix is not positive definite");
            endif
        else
            ## continue only on PD values, but warn about it
            warning ("chol:PD", ...
                     "chol: matrix is not guaranteed to be positive definite");
        endif
    endif
    s = sqrt (alpha);
    A = subsasgn (A, idx_diag, s);
    ## second main formula (subdiagonal entries)
    idx_subdiag = substruct ("()", {k + 1 : n, k});
    A = subsasgn (A, idx_subdiag, ...
                  (subsref (A, idx_subdiag) - ...
                   subsref (A, substruct ("()", {k + 1 : n, 1 : k - 1})) * ...
                   el') ./ s);
endfor
## verified Cholesky decomposition found
L = tril (A); # lower triangular part extracted
switch (option)
    case "lower"
        fact = L;
    case "upper"
        fact = L';
endswitch

endfunction
