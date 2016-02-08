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
## @deftypemethod {@@infsup} {@var{Y} =} powrev2 (@var{A}, @var{C}, @var{Y})
## @deftypemethodx {@@infsup} {@var{Y} =} powrev2 (@var{A}, @var{C})
## 
## Compute the reverse power function for the second parameter.
##
## That is, an enclosure of all @code{y ∈ @var{Y}} where
## @code{pow (a, y) ∈ @var{C}} for any @code{a ∈ @var{A}}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## powrev2 (infsup (2, 5), infsup (3, 6))
##   @result{} ans ⊂ [0.6826, 2.585]
## @end group
## @end example
## @seealso{@@infsup/pow}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2011

function result = powrev2 (a, c, y)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif
if (nargin < 3)
    y = infsup (-inf, inf);
endif
if (not (isa (a, "infsup")))
    a = infsup (a);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

a = intersect (a, infsup (0, inf));
c = intersect (c, infsup (0, inf));

## Resize, if scalar × matrix or vector × matrix or scalar × vector
if (rows (a.inf) ~= rows (c.inf))
    a.inf = ones (rows (c.inf), columns (a.inf)) .* a.inf;
    a.sup = ones (rows (c.inf), columns (a.inf)) .* a.sup;
    c.inf = ones (rows (a.inf), columns (c.inf)) .* c.inf;
    c.sup = ones (rows (a.inf), columns (c.inf)) .* c.sup;
endif
if (rows (a.inf) ~= rows (y.inf))
    a.inf = ones (rows (y.inf), columns (a.inf)) .* a.inf;
    a.sup = ones (rows (y.inf), columns (a.inf)) .* a.sup;
    c.inf = ones (rows (y.inf), columns (c.inf)) .* c.inf;
    c.sup = ones (rows (y.inf), columns (c.inf)) .* c.sup;
    y.inf = ones (rows (a.inf), columns (y.inf)) .* y.inf;
    y.sup = ones (rows (a.inf), columns (y.inf)) .* y.sup;
endif
if (columns (a.inf) ~= columns (c.inf))
    a.inf = ones (rows (a.inf), columns (c.inf)) .* a.inf;
    a.sup = ones (rows (a.inf), columns (c.inf)) .* a.sup;
    c.inf = ones (rows (c.inf), columns (a.inf)) .* c.inf;
    c.sup = ones (rows (c.inf), columns (a.inf)) .* c.sup;
endif
if (columns (a.inf) ~= columns (y.inf))
    a.inf = ones (rows (a.inf), columns (y.inf)) .* a.inf;
    a.sup = ones (rows (a.inf), columns (y.inf)) .* a.sup;
    c.inf = ones (rows (c.inf), columns (y.inf)) .* c.inf;
    c.sup = ones (rows (c.inf), columns (y.inf)) .* c.sup;
    y.inf = ones (rows (y.inf), columns (a.inf)) .* y.inf;
    y.sup = ones (rows (y.inf), columns (a.inf)) .* y.sup;
endif

l = y.inf;
u = y.sup;
emptyresult = isempty (a) | isempty (c) ...
    | (a.sup == 0 & (y.sup <= 0 | c.inf > 0)) ...
    | (y.sup <= 0 & ((a.sup <= 1 & c.sup < 1) | (a.inf > 1 & c.inf > 1))) ...
    | (y.inf >= 0 & ((a.sup <= 1 & c.inf > 1) | (a.inf > 1 & c.sup < 1))) ...
    | (((a.inf == 1 & a.sup == 1) | (y.inf == 0 & y.sup == 0)) ...
        & (c.sup < 1 | c.inf > 1));
l(emptyresult) = inf;
u(emptyresult) = -inf;

## Implements Table B.2 in
## Heimlich, Oliver. 2011. “The General Interval Power Function.”
## Diplomarbeit, Institute for Computer Science, University of Würzburg.
## http://exp.ln0.de/heimlich-power-2011.htm.

## x overlaps/starts/containedBy [0, 1] =======================================
x = a.sup < 1;

select = a.sup == 0 & l < 0;
l(select) = 0;

z = c.sup <= 1;
select = x & z & (a.inf == 0 | c.sup == 1) & l < 0;
l(select) = 0;

z = c.sup > 1 & c.sup < inf;
select = x & z & l < 0;
if (any (any (select)))
    l(select) = max (l(select), ...
        powrev2rounded (a.sup(select), c.sup(select), -inf));
endif

z = c.inf >= 1;
select = x & z & (a.inf == 0 | c.inf == 1) & u > 0;
u(select) = 0;

z = c.inf > 0 & c.inf < 1;
select = x & z & u > 0;
if (any (any (select)))
    u (select) = min (u (select), powrev2rounded (a.sup, c.inf, +inf));
endif

## x containedBy/finishes [0, 1] ==============================================
x = a.inf > 0 & a.inf < 1 & a.sup <= 1;

z = c.sup < 1 & c.sup > 0;
select = x & z & l < inf;
if (any (any (select)))
    l(select) = max (l(select), ...
        powrev2rounded (a.inf(select), c.sup(select), -inf));
endif

z = c.inf > 1 & c.sup < inf;
select = x & z & u > -inf;
if (any (any (select)))
    u(select) = min (u(select), ...
        powrev2rounded (a.inf(select), c.inf (select), +inf));
endif

## ismember (1, x) ============================================================
x = a.sup >= 1 & a.inf <= 1;

z = c.inf == 0 & c.sup == 0;
select = x & z & l < 0;
l(select) = 0;

z = c.sup == inf & c.inf > 1;
select = x & z & u > 0 && a.sup <= 1;
u(select) = 0;

gap.inf = -inf (size (l));
gap.sup = +inf (size (u));

z = c.sup < 1;
select = x & z & a.inf == 0;
gap.sup(select) = 0;
select = x & z & a.sup > 1;
if (any (any (select)))
    gap.inf(select) = powrev2rounded (a.sup(select), c.sup(select), +inf);
endif
select = x & z & a.inf > 0 & a.inf < 1 & a.sup > 1;
if (any (any (select)))
    gap.sup(select) = powrev2rounded(a.inf(select), c.sup(select), -inf);
endif

z = c.inf > 1;
select = x & z & a.inf == 0;
gap.inf(select) = 0;
select = x & z & a.sup > 1;
if (any (any (select)))
    gap.sup(select) = powrev2rounded (a.sup(select), c.inf(select), -inf);
endif
select = x & z & a.inf > 0 & a.inf < 1 & a.sup > 1;
if (any (any (select)))
    gap.inf(select) = powrev2rounded (a.inf(select), c.inf(select), +inf);
endif

z = c.sup < 1 | c.inf > 1;
select = x & z & (l > gap.inf | gap.inf == -inf | (gap.inf == 0 & l == 0)) ...
    & (a.inf >= 1 | a.sup > 1 | a.inf <= 0);
l(select) = max (l(select), gap.sup(select));
select = x & z & (u < gap.sup | gap.sup == inf | (gap.sup == 0 & u == 0)) ...
    & (a.inf >= 1 | a.sup > 1 | a.inf <= 0);
u(select) = min (u(select), gap.inf(select));

## x after [0, 1] =============================================================
x = a.inf > 1;

z = c.sup < 1;
select = x & z & u > -inf;
if (any (any (select)))
    u(select) = min (u(select), ...
        powrev2rounded (a.sup(select), c.sup(select), +inf));
endif

z = c.inf > 0 & c.inf < 1;
select = x & z & l < 0;
if (any (any (select)))
    l(select) = max (l(select), ...
        powrev2rounded (a.inf(select), c.inf(select), -inf));
endif

z = c.inf == 1;
select = x & z & l < 0;
l(select) = 0;

z = c.inf > 1;
select = x & z & l < inf;
if (any (any (select)))
    l(select) = max (l(select), ...
        powrev2rounded (a.sup(select), c.inf(select), -inf));
endif

z = c.sup == 1;
select = x & z & u > 0;
u (select) = 0;

z = c.sup > 1 & c.sup < inf;
select = x & z & u > 0;
if (any (any (select)))
    u(select) = min (u(select), ...
        powrev2rounded (a.inf(select), c.sup(select), +inf));
endif

## ============================================================================

emptyresult = l > u | l == inf | u == -inf;
l(emptyresult) = inf;
u(emptyresult) = -inf;

result = infsup (l, u);

endfunction

function y = powrev2rounded (x, z, direction)
## Return y = log z / log x with directed rounding and limit values

y = nominator = denominator = zeros (size (x));

y (z == inf & x < 1) = -inf;
y (z == inf & x > 1 & x < inf) = inf;

## We do not use log here, because log2 is able to produce some results without
## rounding errors.

rnd_log_numerator_up = (direction > 0) == (sign (x - 1) == sign (z - 1));
select = isfinite (x) & isfinite (z) & rnd_log_numerator_up;
if (any (any (select)))
    denominator (select) = mpfr_function_d ('log2', -inf, x (select));
    nominator (select) = mpfr_function_d ('log2', +inf, z (select));
endif
select = isfinite (x) & isfinite (z) & not (rnd_log_numerator_up);
if (any (any (select)))
    denominator (select) = mpfr_function_d ('log2', +inf, x (select));
    nominator (select) = mpfr_function_d ('log2', -inf, z (select));
endif
select = isfinite (x) & isfinite (z);
if (any (any (select)))
    y (select) = mpfr_function_d ('rdivide', direction, ...
        nominator (select), ...
        denominator (select));
endif

endfunction

%!test "from the documentation string";
%! assert (powrev2 (infsup (2, 5), infsup (3, 6)) == "[0x1.5D7E8F22BA886p-1, 0x1.4AE00D1CFDEB5p1]");
