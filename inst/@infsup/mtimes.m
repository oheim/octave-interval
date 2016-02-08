## Copyright 2014-2016 Oliver Heimlich
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
## @defop Method {@@infsup} mtimes (@var{X}, @var{Y})
## @defopx Method {@@infsup} mtimes (@var{X}, @var{Y}, @var{ACCURACY})
## @defopx Operator {@@infsup} {@var{X} * @var{Y}}
##
## Compute the interval matrix multiplication.
##
## The @var{ACCURACY} can be set to @code{tight} (default) or @code{valid}.
## With @code{valid} accuracy an algorithm for fast matrix multiplication based
## on BLAS routines is used. The latter is published by
## Siegried M. Rump (2012), “Fast interval matrix multiplication,”
## Numerical Algorithms 61(1), 1-34.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup ([1, 2; 7, 15], [2, 2; 7.5, 15]);
## y = infsup ([3, 3; 0, 1], [3, 3.25; 0, 2]);
## x * y
##   @result{} ans = 2×2 interval matrix
##          [3, 6]      [5, 10.5]
##      [21, 22.5]   [36, 54.375]
## @end group
## @end example
## @seealso{@@infsup/mrdivide}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-31

function result = mtimes (x, y, accuracy)

if (nargin < 2 || nargin > 3 || (nargin == 3 && not (ischar (accuracy))))
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
elseif (isa (y, "infsupdec"))
    ## Workaround for bug #42735
    result = mtimes (x, y);
    return
endif

if (isscalar (x) || isscalar (y))
    result = times (x, y);
    return
endif

if (size (x.inf, 2) ~= size (y.inf, 1))
    error ("interval:InvalidOperand", ...
           "operator *: nonconformant arguments");
endif

if (nargin == 3)
    switch (accuracy)
        case "valid"
            ## Fast matrix multiplication uses rounding mode switches, which
            ## might not work on all systems.  Thus, we validate whether the
            ## BLAS routines respect rounding modes correctly on the current
            ## platform and fall back to the slow implementation otherwise.
            persistent use_rounding_mode = check_rounding_mode ();
            if (use_rounding_mode)
                result = fast_mtimes (x, y);
                return
            else
                warning ('interval:rounding', ...
                         ['mtimes: rounding modes not supported, falling ', ...
                          'back to slow but accurate matrix multiplication']);
            endif
        case "tight"
            ## Default mode
        otherwise
            print_usage();
            return
    endswitch
endif

## mtimes could also be computed with a for loop and the dot operation.
## However, that would take significantly longer (loop + missing JIT-compiler,
## several OCT-file calls), so we use an optimized
## OCT-file for that particular operation.

[l, u] = mpfr_matrix_mul_d (x.inf, y.inf, x.sup, y.sup);
result = infsup (l, u);

endfunction

function C = fast_mtimes (A, B)
## Implements Algorithm 4.8
## IImul7: interval interval multiplication with 7 point matrix multiplications
## Rump, Siegried M. 2012. “Fast interval matrix multiplication.”
## Numerical Algorithms 61(1), 1-34.
## http://www.ti3.tu-harburg.de/paper/rump/Ru11a.pdf.
##
## Although this is the slowest of the published fast algorithms, it is the
## most accurate.

[mA, rA] = rad (A);
[mB, rB] = rad (B);
rhoA = sign (mA) .* min (abs (mA), rA);
rhoB = sign (mB) .* min (abs (mB), rB);
unwind_protect
    __setround__ (+inf);
    rC = abs (mA) * rB + rA * (abs (mB) + rB) + (-abs (rhoA)) * abs (rhoB);
    u = mA * mB + rhoA * rhoB + rC;
    __setround__ (-inf);
    l = mA * mB + rhoA * rhoB - rC;
unwind_protect_cleanup
    __setround__ (0.5); # restore default rounding mode (to nearest)
end_unwind_protect

C = infsup (l, u);

endfunction

function works = check_rounding_mode ()

try
    unwind_protect
        works = true ();
        __setround__ (+inf);
        works &= (1 + realmin > 1);
        works &= ([1 1 -1] * [1; realmin; realmin] > 1);
        __setround__ (-inf);
        works &= (1 + realmin == 1);
        works &= ([1 1 -1] * [1; realmin; realmin] < 1);
    unwind_protect_cleanup
        __setround__ (0.5);
    end_unwind_protect
catch
    works = false ();
end_try_catch

endfunction

%!test "from the documentation string";
%! assert (infsup ([1, 2; 7, 15], [2, 2; 7.5, 15]) * infsup ([3, 3; 0, 1], [3, 3.25; 0, 2]) == infsup ([3, 5; 21, 36], [6, 10.5; 22.5, 54.375]));
%!test "matrix multiplication using BLAS routines";
%! assert (mtimes (infsup ([1, 2; 7, 15], [2, 2; 7.5, 15]), infsup ([3, 3; 0, 1], [3, 3.25; 0, 2]), 'valid') == infsup ([3, 5; 21, 36], [6, 10.5; 22.5, 54.375]));
