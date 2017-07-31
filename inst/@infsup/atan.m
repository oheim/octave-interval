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
## @defmethod {@@infsup} atan (@var{X})
##
## Compute the inverse tangent in radians.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## atan (infsup (1))
##   @result{} ans ⊂ [0.78539, 0.7854]
## @end group
## @end example
## @seealso{@@infsup/tan, @@infsup/atan2}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-06

function x = atan (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  ## atan is monotonically increasing
  if (__check_crlibm__ ())
    l = crlibm_function ('atan', -inf, x.inf);
    u = crlibm_function ('atan', +inf, x.sup);
  else
    l = mpfr_function_d ('atan', -inf, x.inf);
    u = mpfr_function_d ('atan', +inf, x.sup);
  endif
  l(l == 0) = -0;

  emptyresult = isempty (x);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (atan (infsup (1)) == "[0x1.921FB54442D18p-1, 0x1.921FB54442D19p-1]");

%!# correct use of signed zeros
%!test
%! x = atan (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.atan;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     atan (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.atan;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (atan (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.atan;
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
%! assert (isequaln (atan (in1), out));
