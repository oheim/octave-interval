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
## @defmethod {@@infsup} realsqrt (@var{X})
##
## Compute the square root (for all non-negative numbers).
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## realsqrt (infsup (-6, 4))
##   @result{} ans = [0, 2]
## @end group
## @end example
## @seealso{@@infsup/sqr, @@infsup/rsqrt, @@infsup/pow, @@infsup/cbrt, @@infsup/nthroot}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-01

function x = realsqrt (x)

  l = mpfr_function_d ('realsqrt', -inf, max (0, x.inf));
  u = mpfr_function_d ('realsqrt', +inf, max (0, x.sup));

  emptyresult = isempty (x) | x.sup < 0;
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  l(l == 0) = -0;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (realsqrt (infsup (-6, 4)) == infsup (0, 2));

%!# correct use of signed zeros
%!test
%! x = realsqrt (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));
%!test
%! x = realsqrt (infsup (0, 2));
%! assert (signbit (inf (x)));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.sqrt;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     realsqrt (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.sqrt;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (realsqrt (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.sqrt;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2)
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (realsqrt (in1), out));
