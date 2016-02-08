## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsupdec} polyval (@var{P}, @var{X})
##
## Evaluate polynomial @var{P} with argument @var{X}.
##
## Horner's scheme is used to evaluate a first approximation.  The result is
## improved with iterative refinement.
##
## Accuracy: The result is a tight enclosure for polynomials of degree 1 or
## less.  For polynomials of higher degree the result is a valid enclosure.
## For @var{X} being no singleton interval, the algorithm suffers from the
## dependency problem.
##
## @example
## @group
## output_precision (16, 'local')
## polyval (infsupdec ([3 4 2 1]), 42) # 3x^3 + 4x^2 + 2x^1 + 1 | x = 42
##   @result{} [229405]_com
## polyval (infsupdec ([3 4 2 1]), "42?") # ... | x = 41.5 .. 42.5
##   @result{} [221393.125, 237607.875]_com
## @end group
## @end example
## @seealso{@@infsup/fzero}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-05-30

function result = polyval (p, x)

if (nargin ~= 2)
    print_usage ();
    return
endif

if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif
if (not (isa (p, "infsupdec")))
    p = infsupdec (p);
endif

if (isnai (p))
    result = p;
    return
endif
if (isnai (x))
    result = x;
    return
endif

result = newdec (polyval (intervalpart (p), intervalpart (x)));
result.dec = min (result.dec, min (min (p.dec), x.dec));

endfunction

%!assert (isequal (polyval (infsupdec (3, "trv"), 0), infsupdec (3, "trv")));
