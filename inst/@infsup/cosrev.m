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
## @deftypemethod {@@infsup} {@var{X} =} cosrev (@var{C}, @var{X})
## @deftypemethodx {@@infsup} {@var{X} =} cosrev (@var{C})
## 
## Compute the reverse cosine function.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{cos (x) ∈ @var{C}}.
## 
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## cosrev (infsup (0), infsup (6, 9))
##   @result{} ans ⊂ [7.8539, 7.854]
## @end group
## @end example
## @seealso{@@infsup/cos}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = cosrev (c, x)

if (nargin > 2)
    print_usage ();
    return
endif

if (nargin < 2)
    x = infsup (-inf, inf);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

arccosine = acos (c);
result = x;

## Resize, if scalar × matrix
if (isscalar (arccosine.inf) ~= isscalar (result.inf))
    arccosine.inf = ones (size (result.inf)) .* arccosine.inf;
    arccosine.sup = ones (size (result.inf)) .* arccosine.sup;
    result.inf = ones (size (arccosine.inf)) .* result.inf;
    result.sup = ones (size (arccosine.inf)) .* result.sup;
endif

result.inf (isempty (arccosine)) = inf;
result.sup (isempty (arccosine)) = -inf;

idx.type = '()';

pi = infsup ("pi");
select = not (isempty (result)) ...
    & not (subset (infsup (0, pi.sup), arccosine));

if (any (any (select)))
    ## Find a smaller upper bound for x, if the restriction from c allows it
    u = inf (size (result.inf));
    select_u = select & result.sup < inf;
    ## Find n, such that result.sup is within a distance of pi/2
    ## around (n + 1/2) * pi.
    n = result.sup;
    n (select_u) = floor (sup (n (select_u) ./ pi));
    arccosineshifted = arccosine;
    idx.subs = {(select_u & rem (n, 2) == 0)};
    arccosineshifted = subsasgn (arccosineshifted, idx, ...
        subsref (arccosine, idx) + subsref (n, idx) .* pi);
    idx.subs = {(select_u & rem (n, 2) ~= 0)};
    arccosineshifted = subsasgn (arccosineshifted, idx, ...
        (infsup (subsref (n, idx)) + 1) .* pi - subsref (arccosine, idx));
    overlapping = not (isempty (intersect (result, arccosineshifted)));
    u (select_u & overlapping) = ...
        min (result.sup (select_u & overlapping), ...
             arccosineshifted.sup (select_u & overlapping));
    m = n;
    m (select_u & ~overlapping) = ...
        mpfr_function_d ('minus', +inf, m (select_u & ~overlapping), 1);
    idx.subs = {(select_u & ~overlapping & rem (n, 2) == 0)};
    u (idx.subs {1}) = ...
        sup (subsref (n, idx) .* pi - subsref (arccosine, idx));
    idx.subs = {(select_u & ~overlapping & rem (n, 2) ~= 0)};
    u (idx.subs {1}) = ...
        sup (subsref (arccosine, idx) + subsref (m, idx) .* pi);

    ## Find a larger lower bound for x, if the restriction from c allows it
    l = -inf (size (result.inf));
    select_l = select & result.inf > -inf;
    ## Find n, such that result.inf is within a distance of pi/2
    ## around (n + 1/2) * pi.
    n = result.inf;
    n (select_l) = floor (inf (n (select_l) ./ pi));
    arccosineshifted = arccosine;
    idx.subs = {(select_l & rem (n, 2) == 0)};
    arccosineshifted = subsasgn (arccosineshifted, idx, ...
        subsref (arccosine, idx) + subsref (n, idx) .* pi);
    idx.subs = {(select_l & rem (n, 2) ~= 0)};
    arccosineshifted = subsasgn (arccosineshifted, idx, ...
        (infsup (subsref (n, idx)) + 1) .* pi - subsref (arccosine, idx));
    overlapping = not (isempty (intersect (result, arccosineshifted)));
    l (select_l & overlapping) = ...
        max (result.inf (select_l & overlapping), ...
             arccosineshifted.inf (select_l & overlapping));
    m = n;
    m (select_l & ~overlapping) = ...
        mpfr_function_d ('plus', -inf, m (select_l & ~overlapping), 1);
    idx.subs = {(select_l & ~overlapping & rem (n, 2) == 0)};
    l (idx.subs {1}) = ...
        inf ((infsup (subsref (m, idx)) + 1) .* pi - subsref (arccosine, idx));
    idx.subs = {(select_l & ~overlapping & rem (n, 2) ~= 0)};
    l (idx.subs {1}) = ...
        inf (subsref (arccosine, idx) + subsref (m, idx) .* pi);
    
    result.inf (select) = max (l (select), result.inf (select));
    result.sup (select) = min (u (select), result.sup (select));
    
    result.inf (result.inf > result.sup) = inf;
    result.sup (result.inf > result.sup) = -inf;
endif

endfunction

%!test "from the documentation string";
%! assert (cosrev (0, infsup (6, 9)) == "[0x1.F6A7A2955385Ep2, 0x1.F6A7A2955386p2]");
