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
## @deftypemethod {@@infsupdec} {@var{X} =} pownrev (@var{C}, @var{X}, @var{P})
## @deftypemethodx {@@infsupdec} {@var{X} =} pownrev (@var{C}, @var{P})
## 
## Compute the reverse monomial @code{x^@var{P}}.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{pown (x, @var{P}) ∈ @var{C}}.
##
## Accuracy: The result is a valid enclosure.  The result is a tight
## enclosure for @var{P} ≥ -2.  The result also is a tight enclosure if the
## reciprocal of @var{P} can be computed exactly in double-precision.
##
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
## No one way of decorating this operations gives useful information in all
## contexts.  Therefore, the result will carry a @code{trv} decoration at best.
##
## @seealso{@@infsupdec/pown}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = pownrev (c, x, p)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif

if (nargin < 3)
    p = x;
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

result = infsupdec (pownrev (intervalpart (c), intervalpart (x), p), "trv");

endfunction

%!assert (isequal (pownrev (infsupdec (25, 36), infsupdec (0, inf), 2), infsupdec (5, 6, "trv")));
