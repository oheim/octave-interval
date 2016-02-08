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
## @deftypemethod {@@infsup} {@var{X} =} powrev1 (@var{B}, @var{C}, @var{X})
## @deftypemethodx {@@infsup} {@var{X} =} powrev1 (@var{B}, @var{C})
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
##   @result{} ans ⊂ [1.2457, 2.4495]
## @end group
## @end example
## @seealso{@@infsup/pow}
## @end deftypemethod

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

x = intersect (x, infsup (0, inf));
c = intersect (c, infsup (0, inf));

## Resize, if scalar × matrix or vector × matrix or scalar × vector
if (rows (b.inf) ~= rows (c.inf))
    b.inf = ones (rows (c.inf), columns (b.inf)) .* b.inf;
    b.sup = ones (rows (c.inf), columns (b.inf)) .* b.sup;
    c.inf = ones (rows (b.inf), columns (c.inf)) .* c.inf;
    c.sup = ones (rows (b.inf), columns (c.inf)) .* c.sup;
endif
if (rows (b.inf) ~= rows (x.inf))
    b.inf = ones (rows (x.inf), columns (b.inf)) .* b.inf;
    b.sup = ones (rows (x.inf), columns (b.inf)) .* b.sup;
    c.inf = ones (rows (x.inf), columns (c.inf)) .* c.inf;
    c.sup = ones (rows (x.inf), columns (c.inf)) .* c.sup;
    x.inf = ones (rows (b.inf), columns (x.inf)) .* x.inf;
    x.sup = ones (rows (b.inf), columns (x.inf)) .* x.sup;
endif
if (columns (b.inf) ~= columns (c.inf))
    b.inf = ones (rows (b.inf), columns (c.inf)) .* b.inf;
    b.sup = ones (rows (b.inf), columns (c.inf)) .* b.sup;
    c.inf = ones (rows (c.inf), columns (b.inf)) .* c.inf;
    c.sup = ones (rows (c.inf), columns (b.inf)) .* c.sup;
endif
if (columns (b.inf) ~= columns (x.inf))
    b.inf = ones (rows (b.inf), columns (x.inf)) .* b.inf;
    b.sup = ones (rows (b.inf), columns (x.inf)) .* b.sup;
    c.inf = ones (rows (c.inf), columns (x.inf)) .* c.inf;
    c.sup = ones (rows (c.inf), columns (x.inf)) .* c.sup;
    x.inf = ones (rows (x.inf), columns (b.inf)) .* x.inf;
    x.sup = ones (rows (x.inf), columns (b.inf)) .* x.sup;
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
