## Copyright 2014-2015 Oliver Heimlich
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
## @deftypefn {Function File} {@var{X} =} powrev1 (@var{B}, @var{C}, @var{X})
## @deftypefnx {Function File} {@var{X} =} powrev1 (@var{B}, @var{C})
## 
## Compute the reverse power function for the first parameter.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{pow (x, b) ∈ @var{C}} for any @code{b ∈ @var{B}}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## powrev1 (infsup (2, 5), infsup (3, 6))
##   @result{} [1.2457309396155171, 2.4494897427831784]
## @end group
## @end example
## @seealso{@@infsup/pow}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2011

function result = powrev1 (b, c, x)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif
if (nargin < 3)
    x = infsup (-inf, inf);
endif
if (not (isa (b, "infsup")))
    b = infsup (b);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

x = x & infsup (0, inf);
c = c & infsup (0, inf);

## Broadcast parameters if necessary
if (isscalar (x.inf))
    if (not (isscalar (c.inf)))
        x.inf = x.inf (ones (size (c.inf)));
        x.sup = x.sup (ones (size (c.inf)));
        if (isscalar (b.inf))
            b.inf = b.inf (ones (size (c.inf)));
            b.sup = b.sup (ones (size (c.inf)));
        endif
    elseif (not (isscalar (b.inf)))
        x.inf = x.inf (ones (size (b.inf)));
        x.sup = x.sup (ones (size (b.inf)));
        c.inf = c.inf (ones (size (b.inf)));
        c.sup = c.sup (ones (size (b.inf)));
    endif
else
    if (isscalar (b.inf))
        b.inf = b.inf (ones (size (x.inf)));
        b.sup = b.sup (ones (size (x.inf)));
    endif
    if (isscalar (c.inf))
        c.inf = c.inf (ones (size (x.inf)));
        c.sup = c.sup (ones (size (x.inf)));
    endif
endif

l = x.inf;
u = x.sup;
emptyresult = isempty (b) | isempty (c) | (x.sup == 0 & b.sup <= 0) ...
    | (b.sup <= 0 & ((x.sup <= 1 & c.sup < 1) | (x.inf >= 1 & c.inf > 1))) ...
    | (b.inf >= 0 & ((x.sup <= 1 & c.inf > 1) | (x.inf >= 1 & c.sup < 1)));
l (emptyresult) = inf;
u (emptyresult) = -inf;

## Implements Table B.1 in
## Heimlich, Oliver. 2011. “The General Interval Power Function.”
## Diplomarbeit, Institute for Computer Science, University of Würzburg.
## http://exp.ln0.de/heimlich-power-2011.htm.

## y before [0, 0] ============================================================
y = b.sup < 0;
z = c.sup < 1;
select = y & z & l < inf;
if (any (any (select)))
    l (select) = max (l (select), ...
        powrev1rounded (c.sup (select), b.inf (select), -inf));
endif

z = c.sup == 1;
select = y & z & l < 1;
l (select) = 1;

z = c.sup > 1 & c.sup < inf;
select = y & z & l < 1;
if (any (any (select)))
    l (select) = max (l (select), ...
        powrev1rounded (c.sup (select), b.sup (select), -inf));
endif

z = c.inf > 0 & c.inf < 1;
select = y & z & u > 1;
if (any (any (select)))
    u (select) = min (u (select), ...
        powrev1rounded (c.inf (select), b.sup (select), +inf));
endif

z = c.inf == 1;
select = y & z & u > 1;
u (select) = 1;

z = c.inf > 1;
select = y & z & u > 0;
if (any (any (select)))
    u (select) = min (u (select), ...
        powrev1rounded (c.inf (select), b.inf (select), +inf));
endif

## ismember (0, y) ============================================================
y = b.inf <= 0 & b.sup >= 0;

gap.inf = -inf (size (l));
gap.sup = +inf (size (u));

z = c.sup < 1;
select = y & z & b.sup > 0;
if (any (any (select)))
    gap.inf (select) = powrev1rounded (c.sup (select), b.sup (select), +inf);
endif
select = y & z & b.inf < 0;
if (any (any (select)))
    gap.sup (select) = powrev1rounded (c.sup (select), b.inf (select), -inf);
endif

z = c.inf > 1;
select = y & z & b.inf < 0;
if (any (any (select)))
    gap.inf (select) = powrev1rounded (c.inf (select), b.inf (select), +inf);
endif
select = y & z & b.sup > 0;
if (any (any (select)))
    gap.sup (select) = powrev1rounded (c.inf (select), b.sup (select), -inf);
endif

z = c.sup < 1 | c.inf > 1;
select = y & z & (l > gap.inf | (gap.inf == 1 & l == 1));
l (select) = max (l (select), gap.sup (select));
select = y & z & (u < gap.sup | gap.sup == inf | (gap.sup == 1 & u == 1));
u (select) = min (u (select), gap.inf (select));

## y after [0, 0] =============================================================
y = b.inf > 0;
z = c.sup < 1;
select = y & z & u > 0;
if (any (any (select)))
    u (select) = min (u (select), ...
        powrev1rounded (c.sup (select), b.sup (select), +inf));
endif

z = c.sup == 1;
select = y & z & u > 1;
u (select) = 1;

z = c.sup > 1 & c.sup < inf;
select = y & z & u > 1;
if (any (any (select)))
    u (select) = min (u (select), ...
        powrev1rounded (c.sup (select), b.inf (select), +inf));
endif

z = c.inf > 0 & c.inf < 1;
select = y & z & l < 1;
if (any (any (select)))
    l (select) = max (l (select), ...
        powrev1rounded (c.inf (select), b.inf (select), -inf));
endif

z = c.inf == 1;
select = y & z & l < 1;
l (select) = 1;

z = c.inf > 1;
select = y & z & l < inf;
if (any (any (select)))
    l (select) = max (l (select), ...
        powrev1rounded (c.inf (select), b.sup (select), -inf));
endif

## ============================================================================

emptyresult = l > u | l == inf | u == -inf;
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

function x = powrev1rounded (z, y, direction)
## Return x = z ^ (1 / y) with directed rounding and limit values

x = ones (size (z));

x ((z == inf & y < 0) | (z == 0 & y > 0)) = 0;
x ((z == inf & y > 0) | (z == 0 & y < 0)) = inf;

select = z > 1 & z < inf & isfinite (y);
y (select) = mpfr_function_d ('rdivide', direction, 1, y (select));
select = z < 1 & z > 0 & isfinite (y);
y (select) = mpfr_function_d ('rdivide', -direction, 1, y (select));
select = isfinite (y) & z > 0 & z ~= 1 & z < inf;
x (select) = mpfr_function_d ('pow', direction, z (select), y (select));

endfunction

%!test "from the documentation string";
%! assert (powrev1 (infsup (2, 5), infsup (3, 6)) == "[0x1.3EE8390D43955, 0x1.3988E1409212Fp1]");
