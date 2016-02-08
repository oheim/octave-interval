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
## @defop Method {@@infsup} mpower (@var{X}, @var{Y})
## @defopx Operator {@@infsup} {@var{X} ^ @var{Y}}
## 
## Return the matrix power operation of @var{X} raised to the @var{Y} power.
##
## If @var{X} is a scalar, this function and @code{power} are equivalent.
## Otherwise, @var{X} must be a square matrix and @var{Y} must be a single
## integer.
##
## Warning: This function is not defined by IEEE Std 1788-2015.
##
## Accuracy: The result is a valid enclosure.  The result is tightest for
## @var{Y} in @{0, 1, 2@}.
##
## @example
## @group
## infsup (magic (3)) ^ 2
##   @result{} ans = 3×3 interval matrix
##      [91]   [67]   [67]
##      [67]   [91]   [67]
##      [67]   [67]   [91]
## @end group
## @end example
## @seealso{@@infsup/pow, @@infsup/pown, @@infsup/pow2, @@infsup/pow10, @@infsup/exp}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-31

function result = mpower (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

if (isscalar (x))
    ## Short-circuit for scalars
    result = power (x, y);
    return
endif

if (not (isreal (y)) || fix (y) ~= y)
    error ("interval:InvalidOperand", ...
           "mpower: only integral powers can be computed");
endif

if (not (issquare (x.inf)))
    error ("interval:InvalidOperand", ...
           "mpower: must be square matrix");
endif

## Implements log-time algorithm A.1 in
## Heimlich, Oliver. 2011. “The General Interval Power Function.”
## Diplomarbeit, Institute for Computer Science, University of Würzburg.
## http://exp.ln0.de/heimlich-power-2011.htm.

result = infsup (eye (length (x)));
while (y ~= 0)
    if (rem (y, 2) == 0) # y is even
        [x.inf, x.sup] = mpfr_matrix_sqr_d (x.inf, x.sup);
        y /= 2;
    else # y is odd
        result = mtimes (result, x);
        if (all (all (isempty (result))) || all (all (isentire (result))))
            ## We can stop the computation here, this is a fixed point
            break
        endif
        if (y > 0)
            y --;
        else
            y ++;
            if (y == 0)
                ## Inversion after computation of a negative power.
                ## Inversion should be the last step, because it is not
                ## tightest and would otherwise increase rounding errors.
                result = inv (result);
            endif
        endif
    endif
endwhile

endfunction

%!xtest "from the documentation string";
%! assert (isequal (infsup (magic (3)) ^ 2, infsup (magic (3) ^ 2)));
