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
## @deftypemethod {@@infsupdec} {@var{X} =} atan2rev2 (@var{A}, @var{C}, @var{X})
## @deftypemethodx {@@infsupdec} {@var{X} =} atan2rev2 (@var{A}, @var{C})
## 
## Compute the reverse atan2 function for the second parameter.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{atan2 (a, x) ∈ @var{C}} for any @code{a ∈ @var{A}}.
##
## Accuracy: The result is a valid enclosure.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## No one way of decorating this operations gives useful information in all
## contexts.  Therefore, the result will carry a @code{trv} decoration at best.
##
## @example
## @group
## atan2rev2 (infsupdec (1, 2), infsupdec ("pi") / 4)
##   @result{} ans ⊂ [0.99999, 2.0001]_trv
## @end group
## @end example
## @seealso{@@infsupdec/atan2}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = atan2rev2 (a, c, x)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif

if (nargin < 3)
    x = infsupdec (-inf, inf);
endif
if (not (isa (a, "infsupdec")))
    a = infsupdec (a);
endif
if (not (isa (c, "infsupdec")))
    c = infsupdec (c);
endif
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

if (isnai (x))
    result = x;
    return
endif
if (isnai (a))
    result = b;
    return
endif
if (isnai (c))
    result = c;
    return
endif

result = atan2rev2 (intervalpart (a), intervalpart (c), intervalpart (x));
## inverse atan2 is not a point function
result = infsupdec (result, "trv");

endfunction

%!test "from the documentation string";
%! assert (isequal (atan2rev2 (infsupdec (1, 2), infsupdec ("pi") / 4), infsupdec ("[0x1.FFFFFFFFFFFFEp-1, 0x1.0000000000001p1]_trv")));
