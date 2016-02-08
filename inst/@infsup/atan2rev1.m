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
## @deftypemethod {@@infsup} {@var{Y} =} atan2rev1 (@var{B}, @var{C}, @var{Y})
## @deftypemethodx {@@infsup} {@var{Y} =} atan2rev1 (@var{B}, @var{C})
## 
## Compute the reverse atan2 function for the first parameter.
##
## That is, an enclosure of all @code{y ∈ @var{Y}} where
## @code{atan2 (y, b) ∈ @var{C}} for any @code{b ∈ @var{B}}.
##
## Accuracy: The result is a valid enclosure.
##
## @example
## @group
## atan2rev1 (infsup (1, 2), infsup ("pi") / 4)
##   @result{} ans ⊂ [0.99999, 2.0001]
## @end group
## @end example
## @seealso{@@infsup/atan2}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = atan2rev1 (b, c, y)

if (nargin < 2 || nargin > 3)
    print_usage ();
    return
endif

if (nargin < 3)
    y = infsup (-inf, inf);
endif
if (not (isa (b, "infsup")))
    b = infsup (b);
endif
if (not (isa (c, "infsup")))
    c = infsup (c);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
endif

## Resize, if scalar × matrix or vector × matrix or scalar × vector
if (rows (b.inf) ~= rows (c.inf))
    b.inf = ones (rows (c.inf), columns (b.inf)) .* b.inf;
    b.sup = ones (rows (c.inf), columns (b.inf)) .* b.sup;
    c.inf = ones (rows (b.inf), columns (c.inf)) .* c.inf;
    c.sup = ones (rows (b.inf), columns (c.inf)) .* c.sup;
endif
if (rows (b.inf) ~= rows (y.inf))
    b.inf = ones (rows (y.inf), columns (b.inf)) .* b.inf;
    b.sup = ones (rows (y.inf), columns (b.inf)) .* b.sup;
    c.inf = ones (rows (y.inf), columns (c.inf)) .* c.inf;
    c.sup = ones (rows (y.inf), columns (c.inf)) .* c.sup;
    y.inf = ones (rows (b.inf), columns (y.inf)) .* y.inf;
    y.sup = ones (rows (b.inf), columns (y.inf)) .* y.sup;
endif
if (columns (b.inf) ~= columns (c.inf))
    b.inf = ones (rows (b.inf), columns (c.inf)) .* b.inf;
    b.sup = ones (rows (b.inf), columns (c.inf)) .* b.sup;
    c.inf = ones (rows (c.inf), columns (b.inf)) .* c.inf;
    c.sup = ones (rows (c.inf), columns (b.inf)) .* c.sup;
endif
if (columns (b.inf) ~= columns (y.inf))
    b.inf = ones (rows (b.inf), columns (y.inf)) .* b.inf;
    b.sup = ones (rows (b.inf), columns (y.inf)) .* b.sup;
    c.inf = ones (rows (c.inf), columns (y.inf)) .* c.inf;
    c.sup = ones (rows (c.inf), columns (y.inf)) .* c.sup;
    y.inf = ones (rows (y.inf), columns (b.inf)) .* y.inf;
    y.sup = ones (rows (y.inf), columns (b.inf)) .* y.sup;
endif

pi = infsup ("pi");
idx.type = '()';

emptyresult = isempty (y) | isempty (b) | isempty (c) | ...
    c.inf >= sup (pi) | c.sup <= inf (-pi);

result = infsup (inf (size (y.inf)), -inf (size (y.inf)));

## c1 is the part of c where y >= 0 and x <= 0
c1 = intersect (c, infsup (inf (pi) / 2, sup (pi)));
select = not (emptyresult | isempty (c1) | ...
    b.inf > 0 | y.sup < 0 | c1.sup == inf (pi) / 2 | ...
    (b.inf >= 0 & y.sup <= 0) | (b.inf >= 0 & c1.inf > inf (pi) / 2));
if (any (any (select)))
    ## The inverse function is y = b * tan (c)
    ## minimum is located at b.sup, c.sup
    ## maximum is located at b.inf, c.inf
    l = zeros (size (result.inf));
    select_l = select & c1.sup < sup (pi) & b.sup < 0;
    l (select_l) = ...
        max (0, ...
             inf (b.sup (select_l) .* tan (infsup (c1.sup (select_l)))));
    u = inf (size (result.inf));
    select_u = select & c1.inf > inf (pi) / 2 & b.inf > -inf;
    u (select_u) = ...
        sup (b.inf (select_u) .* tan (infsup (c1.inf (select_u))));
    idx.subs = {select};
    result = subsasgn (result, idx, ...
        intersect (subsref (y, idx), ...
                   infsup (subsref (l, idx), subsref (u, idx))));
endif

## c2 is the part of c where y >= 0 and x >= 0
c2 = intersect (c, infsup (0, sup (pi) / 2));
select = not (emptyresult | isempty (c2) | b.sup < 0 | y.sup < 0 | ...
    c2.inf == sup (pi) / 2 | ...
    (b.sup <= 0 & y.sup <= 0) | (b.sup <= 0 & c2.sup < sup (pi) / 2));
if (any (any (select)))
    ## The inverse function is y = b * tan (c)
    ## minimum is located at b.inf, c.inf
    ## maximum is located at b.sup, c.sup
    l = zeros (size (result.inf));
    select_l = select & c2.inf > 0 & b.inf > 0;
    l (select_l) = ...
        max (0, ...
             inf (b.inf (select_l) .* tan (infsup (c2.inf (select_l)))));
    u = inf (size (result.inf));
    u (c2.sup == 0) = 0;
    select_u = select & c2.sup ~= 0 & c2.sup < sup (pi) / 2 & b.sup < inf;
    u (select_u) = ...
        sup (b.sup (select_u) .* tan (infsup (c2.sup (select_u))));
    idx.subs = {select};
    result = subsasgn (result, idx, ...
        union (subsref (result, idx), ...
               intersect (subsref (y, idx), ...
                          infsup (subsref (l, idx), subsref (u, idx)))));
endif

## c3 is the part of c where y <= 0 and x >= 0
c3 = intersect (c, infsup (inf (-pi) / 2, 0));
select = not (emptyresult | isempty (c3) | b.sup < 0 | y.inf > 0 | ...
    c3.sup == inf (-pi) / 2 | (b.sup <= 0 & y.inf >= 0) | ...
    (b.sup <= 0 & c2.inf > inf (-pi) / 2));
if (any (any (select)))
    ## The inverse function is y = b * tan (c)
    ## minimum is located at b.sup, c.inf
    ## maximum is located at b.inf, c.sup
    l = -inf (size (result.inf));
    l (c3.inf == 0) = 0;
    select_l = select & c3.inf ~= 0 & c3.inf > inf (-pi) / 2 & b.sup < inf;
    l (select_l) = ...
        inf (b.sup (select_l) .* tan (infsup (c3.inf (select_l))));
    u = zeros (size (result.inf));
    select_u = select & c3.sup ~= 0 & b.inf > 0;
    u (select_u) = ...
        sup (b.inf (select_u) .* tan (infsup (c3.sup (select_u))));
    idx.subs = {select};
    result = subsasgn (result, idx, ...
        union (subsref (result, idx), ...
               intersect (subsref (y, idx), ...
                          infsup (subsref (l, idx), subsref (u, idx)))));
endif

## c4 is the part of c where y <= 0 and x <= 0
c4 = intersect (c, infsup (inf (-pi), sup (-pi) / 2));
select = not (emptyresult | isempty (c4) | b.inf > 0 | y.inf > 0 | ...
    c4.inf == sup (-pi) / 2 | (b.inf >= 0 & y.inf >= 0) | ...
    (b.inf >= 0 & c4.sup < sup (-pi) / 2));
if (any (any (select)))
    ## The inverse function is y = b * tan (c)
    ## minimum is located at b.inf, c.sup
    ## maximum is located at b.sup, c.inf
    l = -inf (size (result.inf));
    select_l = select & c4.sup < sup (-pi) / 2 & b.inf > -inf;
    l (select_l) = ...
        inf (b.inf (select_l) .* tan (infsup (c4.sup (select_l))));
    u = zeros (size (result.inf));
    select_u = select & c4.inf > inf (-pi) & b.sup < 0;
    u (select_u) = ...
        min (0, ...
             sup (b.sup (select_u) .* tan (infsup (c4.sup (select_u)))));
    idx.subs = {select};
    result = subsasgn (result, idx, ...
        union (subsref (result, idx), ...
               intersect (subsref (y, idx), ...
                          infsup (subsref (l, idx), subsref (u, idx)))));
endif

endfunction

%!test "from the documentation string";
%! assert (atan2rev1 (infsup (1, 2), infsup ("pi") / 4) == "[0x1.FFFFFFFFFFFFFp-1, 0x1.0000000000001p1]");
