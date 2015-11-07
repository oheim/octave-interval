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
## @documentencoding UTF-8
## @deftypefn {Function File} {} {} @var{X} ./ @var{Y}
## 
## Divide all numbers of interval @var{X} by all numbers of @var{Y}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## x ./ y
##   @result{} ans = [1, 3]
## @end group
## @end example
## @seealso{@@infsup/recip, @@infsup/times}
## @end deftypefn

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = rdivide (x, y)

if (nargin ~= 2)
    print_usage ();
    return
endif
if (not (isa (x, "infsup")))
    x = infsup (x);
endif
if (not (isa (y, "infsup")))
    y = infsup (y);
elseif (isa (y, "infsupdec"))
    ## Workaround for bug #42735
    result = rdivide (x, y);
    return
endif

## Resize, if scalar × matrix
if (isscalar (x.inf) ~= isscalar (y.inf))
    x.inf = ones (size (y.inf)) .* x.inf;
    x.sup = ones (size (y.inf)) .* x.sup;
    y.inf = ones (size (x.inf)) .* y.inf;
    y.sup = ones (size (x.inf)) .* y.sup;
endif

## Partitionize the function's domain
q1 = x.sup <= 0 & y.sup < 0;
q2 = x.sup <= 0 & y.inf > 0;
q3 = x.sup <= 0 & y.sup == 0;
q4 = x.sup <= 0 & y.sup > 0 & y.inf == 0;
q5 = x.inf >= 0 & x.sup > 0 & y.sup < 0;
q6 = x.inf >= 0 & x.sup > 0 & y.inf > 0;
q7 = x.inf >= 0 & x.sup > 0 & y.sup == 0;
q8 = x.inf >= 0 & x.sup > 0 & y.sup > 0 & y.inf == 0;
q9 = x.inf < 0 & 0 < x.sup & y.sup < 0;
q10 = x.inf < 0 & 0 < x.sup & y.inf > 0;

l = u = zeros (size (x.inf));

l (q1) = mpfr_function_d ('rdivide', -inf, x.sup (q1), y.inf (q1));
l (q2) = mpfr_function_d ('rdivide', -inf, x.inf (q2), y.inf (q2));
l (q3) = mpfr_function_d ('rdivide', -inf, x.sup (q3), y.inf (q3));
l (q4) = -inf;
l (q5) = mpfr_function_d ('rdivide', -inf, x.sup (q5), y.sup (q5));
l (q6) = mpfr_function_d ('rdivide', -inf, x.inf (q6), y.sup (q6));
l (q7) = -inf;
l (q8) = mpfr_function_d ('rdivide', -inf, x.inf (q8), y.sup (q8));
l (q9) = mpfr_function_d ('rdivide', -inf, x.sup (q9), y.sup (q9));
l (q10) = mpfr_function_d ('rdivide', -inf, x.inf (q10), y.inf (q10));
u (q1) = mpfr_function_d ('rdivide', +inf, x.inf (q1), y.sup (q1));
u (q2) = mpfr_function_d ('rdivide', +inf, x.sup (q2), y.sup (q2));
u (q3) = inf;
u (q4) = mpfr_function_d ('rdivide', +inf, x.sup (q4), y.sup (q4));
u (q5) = mpfr_function_d ('rdivide', +inf, x.inf (q5), y.inf (q5));
u (q6) = mpfr_function_d ('rdivide', +inf, x.sup (q6), y.inf (q6));
u (q7) = mpfr_function_d ('rdivide', +inf, x.inf (q7), y.inf (q7));
u (q8) = inf;
u (q9) = mpfr_function_d ('rdivide', +inf, x.inf (q9), y.sup (q9));
u (q10) = mpfr_function_d ('rdivide', +inf, x.sup (q10), y.inf (q10));

entireresult = (y.inf < 0 & y.sup > 0) | (x.inf < 0 & x.sup > 0 & ...
                                          (y.inf == 0 | y.sup == 0));
l (entireresult) = -inf;
u (entireresult) = inf;

zeroresult = x.inf == 0 & x.sup == 0;
l (zeroresult) = u (zeroresult) = 0;

emptyresult = isempty (x) | isempty (y) | (y.inf == 0 & y.sup == 0);
l (emptyresult) = inf;
u (emptyresult) = -inf;

result = infsup (l, u);

endfunction

%!test "from the documentation string";
%! assert (infsup (2, 3) ./ infsup (1, 2) == infsup (1, 3));
