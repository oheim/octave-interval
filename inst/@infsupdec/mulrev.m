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
## @documentencoding utf-8
## @deftypefn {Function File} {@var{X} =} mulrev (@var{B}, @var{C}, @var{X})
## @deftypefnx {Function File} {@var{X} =} mulrev (@var{B}, @var{C})
## @deftypefnx {Function File} {[@var{U}, @var{V}] =} mulrev (@var{B}, @var{C})
## @deftypefnx {Function File} {[@var{U}, @var{V}] =} mulrev (@var{B}, @var{C}, @var{X})
## 
## Compute the reverse multiplication function or the two-output division.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{x .* b ∈ @var{C}} for any @code{b ∈ @var{B}}.
##
## This function is similar to interval division @code{@var{C} ./ @var{B}}.
## However, it treats the case 0/0 as “any real number” instead of “undefined”.
##
## Interval division, considered as a set, can have zero, one or two disjoint
## connected components as a result.  If called with two output parameters,
## this function returns the components separately.  @var{U} contains the
## negative or unique component, whereas @var{V} contains the positive
## component in cases with two components.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## c = infsupdec (1);
## b = infsupdec (-inf, inf);
## [u, v] = mulrev (b, c)
##   @result{} [-Inf, 0]_trv
##   @result{} [0, Inf]_trv
## @end group
## @end example
## @seealso{@@infsupdec/times}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function [u, v] = mulrev (b, c, x)

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
if (not (isa (c, "infsupdec")))
    c = infsupdec (c);
endif
if (not (isa (x, "infsupdec")))
    x = infsupdec (x);
endif

if (isnai (x))
    u = v = x;
    return
endif
if (isnai (b))
    u = v = b;
    return
endif
if (isnai (c))
    u = v = c;
    return
endif

if (nargout < 2)
    u = mulrev (intervalpart (b), intervalpart (c), intervalpart (x));
    u = infsupdec (u, "trv");
else
    [u, v] = mulrev (intervalpart (b), intervalpart (c), intervalpart (x));
    u = infsupdec (u, "trv");
    v = infsupdec (v, "trv");
endif

endfunction
