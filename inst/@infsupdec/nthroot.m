## Copyright 2015 Oliver Heimlich
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
## @deftypefn {Function File} {} nthroot (@var{X}, @var{N})
## 
## Compute the real n-th root of @var{X}.
##
## Accuracy: The result is a valid enclosure.  The result is a tight
## enclosure for @var{n} ≥ -2.  The result also is a tight enclosure if the
## reciprocal of @var{n} can be computed exactly in double-precision.
## @seealso{@@infsupdec/pown, @@infsupdec/pownrev}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-20

function result = nthroot (x, n)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsupdec")))
    x = infsup (x);
endif
if (isnai (x))
    result = x;
    return
endif

result = infsupdec (nthroot (intervalpart (x), n));
result.dec = mindec (result.dec, x.dec);

## nthroot is continuous everywhere, but not defined everywhere
even = mod (n, 2) == 0;
defined = (not (even) & (n > 0 | inf (x) > 0 | sup (x) < 0)) ...
        | (even       & ((n > 0 & inf (x) >= 0) ...
                       | (n < 0 & inf (x) > 0)));
result.dec (not (defined)) = "trv";

endfunction

%!assert (isequal (nthroot (infsupdec (25, 36), 2), infsupdec (5, 6)));
