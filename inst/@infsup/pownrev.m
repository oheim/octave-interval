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
## @deftypefn {Function File} {@var{X} =} pownrev (@var{C}, @var{X}, @var{P})
## @deftypefnx {Function File} {@var{X} =} pownrev (@var{C}, @var{P})
## 
## Compute the reverse monomial @code{x^@var{P}}.
##
## Accuracy: The result is a valid enclosure.  The result is a tight
## enclosure for @var{P} in @{-1, 0, 1, 2@}.  The result is an accurate
## enclosure in cases where @code{recip (infsup (@var{P}))} is a singleton.
##
## @seealso{@@infsup/pown}
## @end deftypefn

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
    error ("InvalidOperand: exponent is not an integer");
endif

assert (isscalar (c) && isscalar (x), "only implemented for interval scalars");

switch p
    case -1
        result = inv (c) & x;
        return
    case 0
        if (ismember (1, c))
            result = x;
        else
            result = infsup ();
        endif
        return
    case 1
        result = x & c;
        return
    case 2
        result = sqrrev(c, x);
        return
endswitch

xp = pow (c, inv (infsup (p)));
if (rem (p, 2) == 0)
    xn = -xp;
else
    xn = -pow (-c, inv (infsup (p)));
endif

if (p > 0 && ismember (0, c))
    ## The pow function will return [Empty] if c contains no positive number.
    ## For p > 0 the monomials must evaluate p^0 == 0.
    xz = infsup (0);
else
    xz = infsup ();
endif

result = (xp & x) | (xn & x) | (xz & x);

endfunction
