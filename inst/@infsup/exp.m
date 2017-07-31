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
## @defmethod {@@infsup} exp (@var{X})
##
## Compute the exponential function.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## exp (infsup (1))
##   @result{} ans ⊂ [2.7182, 2.7183]
## @end group
## @end example
## @seealso{@@infsup/log, @@infsup/pow}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function x = exp (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  ## exp is monotonically increasing from (-inf, 0) to (inf, inf)
  if (__check_crlibm__ ())
    l = crlibm_function ('exp', -inf, x.inf); # this also works for empty intervals
    u = crlibm_function ('exp', +inf, x.sup); # ... this does not
  else
    l = mpfr_function_d ('exp', -inf, x.inf); # this also works for empty intervals
    u = mpfr_function_d ('exp', +inf, x.sup); # ... this does not
  endif

  l(l == 0) = -0;
  u(isempty (x)) = -inf;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (exp (infsup (1)) == infsup ("e"));

%!# correct use of signed zeros
%!test
%! x = exp (infsup (-realmax));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.exp;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     exp (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.exp;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (exp (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.exp;
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
%! assert (isequaln (exp (in1), out));
