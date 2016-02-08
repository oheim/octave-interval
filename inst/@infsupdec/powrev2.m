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
## @deftypemethod {@@infsupdec} {@var{Y} =} powrev2 (@var{A}, @var{C}, @var{Y})
## @deftypemethodx {@@infsupdec} {@var{Y} =} powrev2 (@var{A}, @var{C})
## 
## Compute the reverse power function for the second parameter.
##
## That is, an enclosure of all @code{y ∈ @var{Y}} where
## @code{pow (a, y) ∈ @var{C}} for any @code{a ∈ @var{A}}.
##
## Accuracy: The result is a valid enclosure.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## No one way of decorating this operations gives useful information in all
## contexts.  Therefore, the result will carry a @code{trv} decoration at best.
##
## @example
## @group
## powrev2 (infsupdec (2, 5), infsupdec (3, 6))
##   @result{} ans ⊂ [0.6826, 2.585]_trv
## @end group
## @end example
## @seealso{@@infsupdec/pow}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = powrev2 (a, c, y)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif

if (nargin < 3)
    y = infsupdec (-inf, inf);
endif
if (not (isa (a, "infsupdec")))
    a = infsupdec (a);
endif
if (not (isa (c, "infsupdec")))
    c = infsupdec (c);
endif
if (not (isa (y, "infsupdec")))
    y = infsupdec (y);
endif

if (isnai (y))
    result = y;
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

result = powrev2 (intervalpart (a), intervalpart (c), intervalpart (y));
## inverse power is not a point function
result = infsupdec (result, "trv");

endfunction

%!test "from the documentation string";
%! assert (isequal (powrev2 (infsupdec (2, 5), infsupdec (3, 6)), infsupdec ("[0x1.5D7E8F22BA886p-1, 0x1.4AE00D1CFDEB5p1]_trv")));
