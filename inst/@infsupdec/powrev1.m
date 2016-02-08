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
## @deftypemethod {@@infsupdec} {@var{X} =} powrev1 (@var{B}, @var{C}, @var{X})
## @deftypemethodx {@@infsupdec} {@var{X} =} powrev1 (@var{B}, @var{C})
## 
## Compute the reverse power function for the first parameter.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{pow (x, b) ∈ @var{C}} for any @code{b ∈ @var{B}}.
##
## Accuracy: The result is a valid enclosure.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## No one way of decorating this operations gives useful information in all
## contexts.  Therefore, the result will carry a @code{trv} decoration at best.
##
## @example
## @group
## powrev1 (infsupdec (2, 5), infsupdec (3, 6))
##   @result{} ans ⊂ [1.2457, 2.4495]_trv
## @end group
## @end example
## @seealso{@@infsupdec/pow}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = powrev1 (b, c, x)

if (nargin < 2 || nargin > 3)
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
    c = infsupdec (c);
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

%!test "from the documentation string";
%! assert (isequal (powrev1 (infsupdec (2, 5), infsupdec (3, 6)), infsupdec ("[0x1.3EE8390D43955, 0x1.3988E1409212Fp1]_trv")));
