## Copyright 2014 Oliver Heimlich
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
## @deftypefn {Interval Function} {} @var{X} ^ @var{Y}
## 
## Compute the general power function on intervals, which is defined for
## (1) any positive base @var{X}; (2) @code{@var{X} = 0} when @var{Y} is
## positive; (3) negative base @var{X} together with integral exponent @var{Y}.
##
## This definition complies with the common complex valued power function,
## restricted to the domain where results are real, plus limit values where
## @var{X} is zero.  The complex power function is defined by
## @code{exp (@var{Y} * log (@var{X}))} with initial branch of complex
## logarithm and complex exponential function.
##
## Warning: This function is not defined by IEEE 1788.
##
## Accuracy: The result is an accurate enclosure.  The result is tightest in
## each of the following cases:  @var{X} in @{0, 1, 2, 10@}, or @var{Y} in
## @{-1, 0.5, 0, 1, 2@}, or @var{X} and @var{Y} integral with
## @code{abs (pow (@var{X}, @var{Y})) in [2^-53, 2^53]}
##
## @example
## @group
## infsup (-5, 6) ^ infsup (2, 3)
##   @result{} [-125, +216]
## @end group
## @end example
## @seealso{pow, pown, pow2, pow10, exp}
## @end deftypefn

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
    result = power (x, y);
    return
endif

if (not (isreal (y)) && fix (y) ~= y)
    error ("mpower: only integral powers can be computed");
endif

if (size (x, 1) ~= size (x, 2))
    error ("mpower: must be square matrix");
endif

## Implements log-time algorithm A.1 in
## Heimlich, Oliver. 2011. “The General Interval Power Function.”
## Diplomarbeit, Institute for Computer Science, University of Würzburg.
## http://exp.ln0.de/heimlich-power-2011.htm.

result = infsup (eye (length (x)));
while (y ~= 0)
    if (rem (y, 2) == 0) # y is even
        x = x * x;
        y /= 2;
    else # y is odd
        result = result * x;
        if (min (min (isempty (result))) || min (min (isentire (result))))
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
