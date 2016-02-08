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
## @deftypemethod {@@infsup} {@var{X} =} sinrev (@var{C}, @var{X})
## @deftypemethodx {@@infsup} {@var{X} =} sinrev (@var{C})
## 
## Compute the reverse sine function.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{sin (x) ∈ @var{C}}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## sinrev (infsup (-1), infsup (0, 6))
##   @result{} ans ⊂ [4.7123, 4.7124]
## @end group
## @end example
## @seealso{@@infsup/sin}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = sinrev (c, x)

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

arcsine = asin (c);
result = x;

## Resize, if scalar × matrix
if (isscalar (arcsine.inf) ~= isscalar (result.inf))
    arcsine.inf = ones (size (result.inf)) .* arcsine.inf;
    arcsine.sup = ones (size (result.inf)) .* arcsine.sup;
    result.inf = ones (size (arcsine.inf)) .* result.inf;
    result.sup = ones (size (arcsine.inf)) .* result.sup;
endif

result.inf (isempty (arcsine)) = inf;
result.sup (isempty (arcsine)) = -inf;

idx.type = '()';

pi = infsup ("pi");
select = not (isempty (result)) ...
    & not (subset (infsup (-pi.sup / 2, pi.sup / 2), arcsine));
    
if (any (any (select)))
    ## Find a smaller upper bound for x, if the restriction from c allows it
    u = inf (size (result.inf));
    select_u = select & result.sup < inf;
    ## Find n, such that result.sup is within a distance of pi/2 around n * pi.
    n = result.sup;
    n (select_u) = ceil (floor (sup (n (select_u) ./ (pi ./ 2))) ./ 2);
    arcsineshifted = arcsine;
    idx.subs = {(select_u & rem (n, 2) == 0)};
    arcsineshifted = subsasgn (arcsineshifted, idx, ...
        subsref (arcsineshifted, idx) + subsref (n, idx) .* pi);
    idx.subs = {(select_u & rem (n, 2) ~= 0)};
    arcsineshifted = subsasgn (arcsineshifted, idx, ...
        subsref (n, idx) .* pi - subsref (arcsineshifted, idx));
    overlapping = not (isempty (intersect (result, arcsineshifted)));
    u (select_u & overlapping) = ...
        min (result.sup (select_u & overlapping), ...
             arcsineshifted.sup (select_u & overlapping));
    m = n;
    m (select_u & ~overlapping) = ...
        mpfr_function_d ('minus', +inf, m (select_u & ~overlapping), 1);
    idx.subs = {(select_u & ~overlapping & rem (n, 2) == 0)};
    u (idx.subs {1}) = ...
        sup (subsref (m, idx) .* pi - subsref (arcsine, idx));
    idx.subs = {(select_u & ~overlapping & rem (n, 2) ~= 0)};
    u (idx.subs {1}) = ...
        sup (subsref (arcsine, idx) + subsref (m, idx) .* pi);
    
    ## Find a larger lower bound for x, if the restriction from c allows it
    l = -inf (size (result.inf));
    select_l = select & result.inf > -inf;
    ## Find n, such that result.inf is within a distance of pi/2 around n * pi.
    n = result.inf;
    n (select_l) = floor (ceil (inf (n (select_l) ./ (pi ./ 2))) ./ 2);
    arcsineshifted = arcsine;
    idx.subs = {(select_l & rem (n, 2) == 0)};
    arcsineshifted = subsasgn (arcsineshifted, idx, ...
        subsref (arcsineshifted, idx) + subsref (n, idx) .* pi);
    idx.subs = {(select_l & rem (n, 2) ~= 0)};
    arcsineshifted = subsasgn (arcsineshifted, idx, ...
        subsref (n, idx) .* pi - subsref (arcsineshifted, idx));
    overlapping = not (isempty (intersect (result, arcsineshifted)));
    l (select_l & overlapping) = ...
        max (result.inf (select_l & overlapping), ...
             arcsineshifted.inf (select_l & overlapping));
    m = n;
    m (select_l & ~overlapping) = ...
        mpfr_function_d ('plus', -inf, m (select_l & ~overlapping), 1);
    idx.subs = {(select_l & ~overlapping & rem (n, 2) == 0)};
    l (idx.subs {1}) = ...
        inf (subsref (m, idx) .* pi - subsref (arcsine, idx));
    idx.subs = {(select_l & ~overlapping & rem (n, 2) ~= 0)};
    l (idx.subs {1}) = ...
        inf (subsref (arcsine, idx) + subsref (m, idx) .* pi);
    
    result.inf (select) = max (l (select), result.inf (select));
    result.sup (select) = min (u (select), result.sup (select));
    
    result.inf (result.inf > result.sup) = inf;
    result.sup (result.inf > result.sup) = -inf;
endif

endfunction

%!test "from the documentation string";
%! assert (sinrev (infsup (-1), infsup (0, 6)) == "[0x1.2D97C7F3321D2p2, 0x1.2D97C7F3321D3p2]");
