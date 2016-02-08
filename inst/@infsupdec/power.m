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
## @defop Method {@@infsupdec} power (@var{X}, @var{Y})
## @defopx Operator {@@infsupdec} {@var{X} .^ @var{Y}}
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
## Warning: This function is not defined by IEEE Std 1788-2015.  However, it
## has been published as “pow2” in O. Heimlich, M. Nehmeier, J. Wolff von
## Gudenberg. 2013. “Variants of the general interval power function.”
## Soft Computing. Volume 17, Issue 8, pp 1357–1366.
## Springer Berlin Heidelberg. DOI 10.1007/s00500-013-1008-8.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## infsupdec (-5, 6) .^ infsupdec (2, 3)
##   @result{} ans = [-125, +216]_trv
## @end group
## @end example
## @seealso{@@infsupdec/pow, @@infsupdec/pown, @@infsupdec/pow2, @@infsupdec/pow10, @@infsupdec/exp}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-15

function result = power (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif

if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif

if (isnai (x))
    result = x;
    return
endif
if (isnai (y))
    result = y;
    return
endif

result = newdec (power (intervalpart (x), intervalpart (y)));
result.dec = min (result.dec, min (x.dec, y.dec));

## The general power function is continuous where it is defined
domain = not (isempty (result)) & (...
            inf (x) > 0 | ... # defined for all x > 0
            (inf (x) == 0 & inf (y) > 0) | ... # defined for x = 0 if y > 0
            # defined for x < 0 only where y is integral
            (issingleton (y) & fix (inf (y)) == inf (y) & ... 
                (inf (y) > 0 | not (ismember (0, x))))); # not defined for 0^0
result.dec (not (domain)) = _trv ();

endfunction

%!test "from the documentation string";
%! assert (isequal (infsupdec (-5, 6) .^ infsupdec (2, 3), infsupdec (-125, 216, "trv")));
