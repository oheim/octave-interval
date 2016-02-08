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
## @deftypemethod {@@infsup} {@var{X} =} atan2rev2 (@var{A}, @var{C}, @var{X})
## @deftypemethodx {@@infsup} {@var{X} =} atan2rev2 (@var{A}, @var{C})
## 
## Compute the reverse atan2 function for the second parameter.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{atan2 (a, x) ∈ @var{C}} for any @code{a ∈ @var{A}}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## atan2rev2 (infsup (1, 2), infsup ("pi") / 4)
##   @result{} ans ⊂ [0.99999, 2.0001]
## @end group
## @end example
## @seealso{@@infsup/atan2}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = atan2rev2 (a, c, x)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif

if (nargin < 3)
    x = infsup (-inf, inf);
endif
if (not (isa (a, "infsup")))
    a = infsup (a);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif

## Resize, if scalar × matrix or vector × matrix or scalar × vector
if (rows (a.inf) ~= rows (c.inf))
    a.inf = ones (rows (c.inf), columns (a.inf)) .* a.inf;
    a.sup = ones (rows (c.inf), columns (a.inf)) .* a.sup;
    c.inf = ones (rows (a.inf), columns (c.inf)) .* c.inf;
    c.sup = ones (rows (a.inf), columns (c.inf)) .* c.sup;
endif
if (rows (a.inf) ~= rows (x.inf))
    a.inf = ones (rows (x.inf), columns (a.inf)) .* a.inf;
    a.sup = ones (rows (x.inf), columns (a.inf)) .* a.sup;
    c.inf = ones (rows (x.inf), columns (c.inf)) .* c.inf;
    c.sup = ones (rows (x.inf), columns (c.inf)) .* c.sup;
    x.inf = ones (rows (a.inf), columns (x.inf)) .* x.inf;
    x.sup = ones (rows (a.inf), columns (x.inf)) .* x.sup;
endif
if (columns (a.inf) ~= columns (c.inf))
    a.inf = ones (rows (a.inf), columns (c.inf)) .* a.inf;
    a.sup = ones (rows (a.inf), columns (c.inf)) .* a.sup;
    c.inf = ones (rows (c.inf), columns (a.inf)) .* c.inf;
    c.sup = ones (rows (c.inf), columns (a.inf)) .* c.sup;
endif
if (columns (a.inf) ~= columns (x.inf))
    a.inf = ones (rows (a.inf), columns (x.inf)) .* a.inf;
    a.sup = ones (rows (a.inf), columns (x.inf)) .* a.sup;
    c.inf = ones (rows (c.inf), columns (x.inf)) .* c.inf;
    c.sup = ones (rows (c.inf), columns (x.inf)) .* c.sup;
    x.inf = ones (rows (x.inf), columns (a.inf)) .* x.inf;
    x.sup = ones (rows (x.inf), columns (a.inf)) .* x.sup;
endif

pi = infsup ("pi");
idx.type = '()';

emptyresult = isempty (x) | isempty (a) | isempty (c) | ...
    c.inf >= sup (pi) | c.sup <= inf (-pi);

result = infsup (inf (size (x.inf)), -inf (size (x.inf)));

## c1 is the part of c where y >= 0 and x <= 0
c1 = intersect (c, infsup (inf (pi) / 2, sup (pi)));
select = not (emptyresult | isempty (c1) | x.inf > 0 | a.sup < 0 | ...
    c1.sup == inf (pi) / 2 | ...
    (x.inf >= 0 & a.sup <= 0) | (a.sup <= 0 & c1.inf > inf (pi) / 2));
if (any (any (select)))
    ## The inverse function is x = a / tan (c)
    ## minimum is located at a.sup, c.sup
    ## maximum is located at a.inf, c.inf
    l = -inf (size (result.inf));
    select_l = select & c1.sup < sup (pi) & a.sup < inf;
    l (select_l) = ...
        inf (a.sup (select_l) ./ tan (infsup (c1.sup (select_l))));
    u = zeros (size (result.inf));
    select_u = select & c1.inf > inf (pi) / 2 & a.inf > 0;
    u (select_u) = ...
        sup (a.inf (select_u) ./ tan (infsup (c1.inf (select_u))));
    idx.subs = {select};
    result = subsasgn (result, idx, ...
        intersect (subsref (x, idx), ...
                   infsup (subsref (l, idx), subsref (u, idx))));
endif

## c2 is the part of c where y >= 0 and x >= 0
c2 = intersect (c, infsup (0, sup (pi) / 2));
select = not (emptyresult | isempty (c2) | x.sup < 0 | a.sup < 0 | ...
    c2.inf == sup (pi) / 2 | ...
    (x.sup <= 0 & a.sup <= 0) | (c2.sup <= 0 & a.inf > 0) | ...
    (a.sup <= 0 & c2.inf > 0));
if (any (any (select)))
    ## The inverse function is x = a / tan (c)
    ## minimum is located at a.inf, c.sup
    ## maximum is located at a.sup, c.inf
    l = zeros (size (result.inf));
    select_l = select & c2.sup ~= 0 & c2.sup < sup (pi) / 2;
    l (select_l) = ...
        max (0, ...
             inf (a.inf (select_l) ./ tan (infsup (c2.sup (select_l)))));
    u = inf (size (result.inf));
    select_u = select & c2.inf ~= 0 & c2.sup ~= 0 & a.sup < inf;
    u (select_u) = ...
        sup (a.sup (select_u) ./ tan (infsup (c2.inf (select_u))));
    idx.subs = {select};
    result = subsasgn (result, idx, ...
        union (subsref (result, idx), ...
               intersect (subsref (x, idx), ...
                          infsup (subsref (l, idx), subsref (u, idx)))));
endif

## c3 is the part of c where y <= 0 and x >= 0
c3 = intersect (c, infsup (inf (-pi) / 2, 0));
select = not (emptyresult | isempty (c3) | x.sup < 0 | a.inf > 0 | ...
    c3.sup == inf (-pi) / 2 | (x.sup <= 0 & a.inf >= 0) | ...
    (c3.inf >= 0 & a.sup < 0) | (a.inf >= 0 & c3.sup < 0));
if (any (any (select)))
    ## The inverse function is x = a / tan (c)
    ## minimum is located at a.sup, c.inf
    ## maximum is located at a.inf, c.sup
    l = zeros (size (result.inf));
    select_l = select & c3.inf > inf (-pi) / 2 & c3.inf ~= 0;
    l (select_l) = ...
        max (0, ...
             inf (a.sup (select_l) ./ tan (infsup (c3.inf (select_l)))));
    u = inf (size (result.inf));
    select_u = select & c3.inf ~= 0 & c3.sup ~= 0 & a.inf < inf;
    u (select_u) = ...
        sup (a.inf (select_u) ./ tan (infsup (c3.sup (select_u))));
    idx.subs = {select};
    result = subsasgn (result, idx, ...
        union (subsref (result, idx), ...
               intersect (subsref (x, idx), ...
                          infsup (subsref (l, idx), subsref (u, idx)))));
endif

## c4 is the part of c where y <= 0 and x <= 0
c4 = intersect (c, infsup (inf (-pi), sup (-pi) / 2));
select = not (emptyresult | isempty (c4) | x.inf > 0 | a.inf > 0 | ...
    c4.inf == sup (-pi) / 2 | (x.inf >= 0 & a.inf >= 0) | ...
    (a.inf >= 0 & c4.inf > inf (-pi)));
if (any (any (select)))
    ## The inverse function is x = a / tan (c)
    ## minimum is located at a.inf, c.inf
    ## maximum is located at a.sup, c.sup
    l = -inf (size (result.inf));
    select_l = select & c4.inf > inf (-pi) & a.inf > -inf;
    l (select_l) = ...
        inf (a.inf (select_l) ./ tan (infsup (c4.inf (select_l))));
    u = zeros (size (result.inf));
    select_u = select & c4.sup < sup (-pi) / 2 & a.sup < 0;
    u (select_u) = ...
        sup (a.sup (select_u) ./ tan (infsup (c4.sup (select_u))));
    idx.subs = {select};
    result = subsasgn (result, idx, ...
        union (subsref (result, idx), ...
               intersect (subsref (x, idx), ...
                          infsup (subsref (l, idx), subsref (u, idx)))));
endif

endfunction

%!test "from the documentation string";
%! assert (atan2rev2 (infsup (1, 2), infsup ("pi") / 4) == "[0x1.FFFFFFFFFFFFEp-1, 0x1.0000000000001p1]");
