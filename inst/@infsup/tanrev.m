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
## @deftypemethod {@@infsup} {@var{X} =} tanrev (@var{C}, @var{X})
## @deftypemethodx {@@infsup} {@var{X} =} tanrev (@var{C})
## 
## Compute the reverse tangent function.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{tan (x) ∈ @var{C}}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## tanrev (infsup (0), infsup (2, 4))
##   @result{} ans ⊂ [3.1415, 3.1416]
## @end group
## @end example
## @seealso{@@infsup/tan}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = tanrev (c, x)

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

arctangent = atan (c);
result = x;

## Resize, if scalar × matrix
if (isscalar (arctangent.inf) ~= isscalar (result.inf))
    arctangent.inf = ones (size (result.inf)) .* arctangent.inf;
    arctangent.sup = ones (size (result.inf)) .* arctangent.sup;
    result.inf = ones (size (arctangent.inf)) .* result.inf;
    result.sup = ones (size (arctangent.inf)) .* result.sup;
endif

result.inf (isempty (arctangent)) = inf;
result.sup (isempty (arctangent)) = -inf;

idx.type = '()';

pi = infsup ("pi");
select = not (isempty (result)) ...
    & not (subset (infsup (-pi.sup / 2, pi.sup / 2), arctangent));

if (any (any (select)))
    ## Find a smaller upper bound for x, if the restriction from c allows it
    u = inf (size (result.inf));
    select_u = select & result.sup < inf;
    ## Find n, such that result.sup is within a distance of pi/2 around n * pi.
    n = result.sup;
    n (select_u) = ceil (floor (sup (n (select_u) ./ (pi ./ 2))) ./ 2);
    arctangentshifted = arctangent;
    idx.subs = {select_u};
    arctangentshifted = subsasgn (arctangentshifted, idx, ...
        subsref (arctangentshifted, idx) + n (select_u) .* pi);
    overlapping = not (isempty (intersect (result, arctangentshifted)));
    u (select_u & overlapping) = ...
        min (result.sup (select_u & overlapping), ...
             arctangentshifted.sup (select_u & overlapping));
    n (select_u & ~overlapping) = ...
        mpfr_function_d ('minus', +inf, n (select_u & ~overlapping), 1);
    idx.subs = {(select_u & ~overlapping)};
    u (idx.subs {1}) = ...
        sup (subsref (arctangent, idx) + subsref (n, idx) .* pi);
    
    ## Find a larger lower bound for x, if the restriction from c allows it
    l = -inf (size (result.inf));
    select_l = select & result.inf > -inf;
    ## Find n, such that result.inf is within a distance of pi/2 around n * pi.
    n = result.inf;
    n (select_l) = floor (ceil (inf (n (select_l) ./ (pi ./ 2))) ./ 2);
    arctangentshifted = arctangent;
    idx.subs = {select_l};
    arctangentshifted = subsasgn (arctangentshifted, idx, ...
        subsref (arctangentshifted, idx) + n (select_l) .* pi);
    overlapping = not (isempty (intersect (result, arctangentshifted)));
    l (select_l & overlapping) = ...
        max (result.inf (select_l & overlapping), ...
            arctangentshifted.inf (select_l & overlapping));
    n (select_l & ~overlapping) = ...
        mpfr_function_d ('plus', -inf, n (select_l & ~overlapping), 1);
    idx.subs = {(select_l & ~overlapping)};
    l (idx.subs {1}) = ...
        inf (subsref (arctangent, idx) + subsref (n, idx) .* pi);
    
    result.inf (select) = max (l (select), result.inf (select));
    result.sup (select) = min (u (select), result.sup (select));
    
    result.inf (result.inf > result.sup) = inf;
    result.sup (result.inf > result.sup) = -inf;
endif

endfunction

%!test "from the documentation string";
%! assert (tanrev (infsup (0), infsup (2, 4)) == infsup ("pi"));
