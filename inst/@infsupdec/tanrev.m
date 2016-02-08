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
## @deftypemethod {@@infsupdec} {@var{X} =} tanrev (@var{C}, @var{X})
## @deftypemethodx {@@infsupdec} {@var{X} =} tanrev (@var{C})
## 
## Compute the reverse tangent function.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{tan (x) ∈ @var{C}}.
##
## Accuracy: The result is a valid enclosure.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## No one way of decorating this operations gives useful information in all
## contexts.  Therefore, the result will carry a @code{trv} decoration at best.
##
## @example
## @group
## tanrev (infsupdec (0), infsupdec (2, 4))
##   @result{} ans ⊂ [3.1415, 3.1416]_trv
## @end group
## @end example
## @seealso{@@infsupdec/tan}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = tanrev (c, x)

if (nargin > 2)
    print_usage ();
    return
endif

if (nargin < 2)
    x = infsupdec (-inf, inf);
endif
if (not (isa (c, "infsupdec")))
    c = infsupdec (c);
endif
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

if (isnai (c))
    result = c;
    return
endif
if (isnai (x))
    result = x;
    return
endif

result = infsupdec (tanrev (intervalpart (c), intervalpart (x)), "trv");

endfunction

%!test "from the documentation string";
%! assert (isequal (tanrev (infsupdec (0), infsupdec (2, 4)), infsupdec ("pi", "trv")));
