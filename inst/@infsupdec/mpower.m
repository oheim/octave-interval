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
## @deftypefn {Interval Function} {@var{Y} =} @var{X} ^ @var{Y}
## 
## Compute the general power function on intervals, which is defined for
## (1) any positive base @var{X}; (2) @code{@var{X} = 0} when @var{Y} is
## positive; (3) negative base @var{X} together with integral exponent @var{Y}.
##
## This definition complies with the common complex valued power function,
## restricted to the domain where results are real.  The complex power function
## is defined by @code{exp (@var{Y} * log (@var{X}))} with initial branch of
## complex logarithm and complex exponential function.
##
## Accuracy: The result is an accurate enclosure.  The result is tightest in
## each of the following cases:  @var{X} in @{0, 1, 2, 10@}, or @var{Y} in
## @{-1, 0.5, 0, 1, 2@}, or @var{X} and @var{Y} integral with
## @code{abs (pow (@var{X}, @var{Y})) in [2^-53, 2^53]}
##
## @example
## @group
## infsupdec (-5, 6) ^ infsupdec (2, 3)
##   @result{} [-125, +216]_trv
## @end group
## @end example
## @seealso{pow, pown, pow2, pow10, exp}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-15

function z = mpower (x, y)

assert (nargin == 2);

## Convert first parameter into interval, if necessary
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

## Convert second parameter into interval, if necessary
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif

if (isnai (x))
    z = x;
    return
endif

if (isnai (y))
    z = y;
    return
endif

z = mpower (intervalpart (x), intervalpart (y));
## The general power function is continuous where it is defined
if (not (isempty (z)) && ...
    (inf (x) > 0 || ... # defined for all x > 0
        (inf (x) == 0 && inf (y) > 0) || ... # defined for x = 0 if y > 0
        (issingleton (y) && fix (inf (y)) == inf (y) && ... # defined for x < 0
                                                            # only where y is
                                                            # integral
            (inf (y) ~= 0 || not (ismember (0, x)))))) # not defined for 0 ^ 0
    z = decorateresult (z, {x, y});
else
    z = decorateresult (z, {x, y}, "trv");
endif

endfunction
