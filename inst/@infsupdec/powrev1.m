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
## @deftypefn {Interval Function} {@var{X} =} powrev1 (@var{B}, @var{C}, @var{X})
## @deftypefnx {Interval Function} {@var{X} =} powrev1 (@var{B}, @var{C})
## @cindex IEEE1788 powRev1
## 
## Compute the reverse power function with
## @code{pow (@var{X}, @var{B}) = @var{C}}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## powrev1 (infsupdec (2, 5), infsupdec (3, 6))
##   @result{} [1.2457309396155171, 2.4494897427831784]_trv
## @end group
## @end example
## @seealso{pow}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = powrev1 (b, c, x)

if (nargin < 2)
    print_usage ();
    return
endif
if (nargin < 3)
    x = infsupdec (-inf, inf);
endif
if (not (isa (b, "infsupdec")))
    b = infsupdec (b);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

if (isnai (x))
    result = x;
    return
endif
if (isnai (b))
    result = b;
    return
endif
if (isnai (c))
    result = c;
    return
endif

result = powrev1 (intervalpart (b), intervalpart (c), intervalpart (x));
## inverse power is not a point function
result = infsupdec (result, "trv");

endfunction
