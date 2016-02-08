## Copyright 2015-2016 Oliver Heimlich
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
## @defmethod {@@infsup} csch (@var{X})
## 
## Compute the hyperbolic cosecant, that is the reciprocal hyperbolic sine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## csch (infsup (1))
##   @result{} ans ⊂ [0.85091, 0.85092]
## @end group
## @end example
## @seealso{@@infsup/sinh, @@infsup/sech, @@infsup/coth}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-03-15

function result = csch (x)

if (nargin ~= 1)
    print_usage ();
    return
endif

l = u = zeros (size (x.inf));

select = x.inf >= 0 | x.sup <= 0;
if (any (any (select)))
    l (select) = mpfr_function_d ('csch', -inf, x.sup (select));
    l (select & x.sup == 0) = -inf;
    u (select) = mpfr_function_d ('csch', +inf, x.inf (select));
    u (select & x.inf == 0) = inf;
endif
select = x.inf < 0 & x.sup > 0;
if (any (any (select)))
    l (select) = -inf;
    u (select) = inf;
endif

emptyresult = isempty (x) | (x.inf == 0 & x.sup == 0);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (csch (infsup (1)) == "[0x1.B3AB8A78B90Cp-1, 0x1.B3AB8A78B90C1p-1]");
