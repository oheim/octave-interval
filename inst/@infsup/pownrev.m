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
## @deftypemethod {@@infsup} {@var{X} =} pownrev (@var{C}, @var{X}, @var{P})
## @deftypemethodx {@@infsup} {@var{X} =} pownrev (@var{C}, @var{P})
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
## @seealso{@@infsup/pown}
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
    x = infsup (-inf, inf);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

if (not (isnumeric (p)) || fix (p) ~= p)
    error ("interval:InvalidOperand", "pownrev: exponent is not an integer");
endif

## Resize, if scalar × matrix
if (isscalar (x.inf) ~= isscalar (c.inf))
    x.inf = x.inf (ones (size (c.inf)));
    x.sup = x.sup (ones (size (c.inf)));
    c.inf = c.inf (ones (size (x.inf)));
    c.sup = c.sup (ones (size (x.inf)));
endif

if (p == 0) # x^p == 1
    result = x;
    emptyresult = c.inf > 1 | c.sup < 1;
    result.inf (emptyresult) = inf;
    result.sup (emptyresult) = -inf;
else
    even = mod (p, 2) == 0;
    if (even)
        result = union (...
                intersect (x, nthroot (intersect (c, infsup (0, inf)), p)), ...
                intersect (x, -nthroot (intersect (c, infsup (0, inf)), p)));
    else
        result = union (...
                intersect (x, nthroot (intersect (c, infsup (0, inf)), p)), ...
                intersect (x, nthroot (intersect (c, infsup (-inf, 0)), p)));
    endif
endif

endfunction

%!assert (pownrev (infsup (25, 36), infsup (0, inf), 2) == infsup (5, 6));
