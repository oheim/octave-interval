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
## @defmethod {@@infsup} pown (@var{X}, @var{P})
## 
## Compute the monomial @code{x^@var{P}} for all numbers in @var{X}.
##
## Monomials are defined for all real numbers and the special monomial
## @code{@var{P} == 0} evaluates to @code{1} everywhere.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## pown (infsup (5, 6), 2)
##   @result{} ans = [25, 36]
## @end group
## @end example
## @seealso{@@infsup/pow, @@infsup/pow2, @@infsup/pow10, @@infsup/exp}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-04

function result = pown (x, p)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isnumeric (p)) || any (any (fix (p) ~= p)))
    error ("interval:InvalidOperand", "pown: exponent is not an integer");
endif

## Resize, if scalar × matrix
if (isscalar (x.inf) ~= isscalar (p))
    x.inf = ones (size (p)) .* x.inf;
    x.sup = ones (size (p)) .* x.sup;
    p = ones (size (x.inf)) .* p;
endif

result = x; % already correct for p == 1

select = (p == 0 & not (isempty (x)));
result.inf(select) = result.sup(select) = 1;

idx.type = "()";
idx.subs = {(p == 2)}; # x^2
if (any (any (idx.subs{1})))
    result = subsasgn (result, idx, sqr (subsref (x, idx)));
endif

idx.subs = {(p == -1)}; # x^-1 = 1./x
if (any (any (idx.subs{1})))
    result = subsasgn (result, idx, 1 ./ subsref (x, idx));
endif

idx.subs = {(rem (p, 2) == 0 & p ~= 2 & p ~= 0)};
if (any (any (idx.subs{1}))) # p even
    x_mig = mig (subsref (x, idx));
    x_mig(isnan (x_mig)) = inf;

    x_mag = mag (subsref (x, idx));
    x_mag(isnan (x_mag)) = -inf;
    
    x.inf = subsasgn (x.inf, idx, x_mig);
    x.sup = subsasgn (x.sup, idx, x_mag);
    
    result = subsasgn (result, idx, pow (subsref (x, idx), subsref (p, idx)));
endif

idx.subs = {(rem (p, 2) ~= 0 & p ~= -1)};
if (any (any (idx.subs{1}))) # p odd
    x_idx = subsref (x, idx);
    p_idx = infsup (subsref (p, idx));
    result = subsasgn (result, idx, ...
                        union (pow (x_idx, p_idx), ...
                              -pow (-x_idx, p_idx)));
endif

## Special case: x = [0]. The pow function used above would be undefined.
select = (p > 0 & x.inf == 0 & x.sup == 0);
result.inf(select) = -0;
result.sup(select) = +0;

endfunction

function result = sqr (x)
## Compute the square for each entry in @var{X}.
##
## Accuracy: The result is a tight enclosure.

l = mpfr_function_d ('sqr', -inf, mig (x));
u = mpfr_function_d ('sqr', +inf, mag (x));

emptyresult = isempty (x);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (pown (infsup (5, 6), 2) == infsup (25, 36));
%!assert (pown (infsup (-2, 1), 2) == infsup (0, 4));
