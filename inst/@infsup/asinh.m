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
## @defmethod {@@infsup} asinh (@var{X})
##
## Compute the inverse hyperbolic sine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## asinh (infsup (1))
##   @result{} ans ⊂ [0.88137, 0.88138]
## @end group
## @end example
## @seealso{@@infsup/sinh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function x = asinh (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  ## asinh is monotonically increasing
  ## This also works for empty intervals!
  l = mpfr_function_d ('asinh', -inf, x.inf);
  u = mpfr_function_d ('asinh', +inf, x.sup);
  l(l == 0) = -0;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (asinh (infsup (1)) == "[0x1.C34366179D426p-1, 0x1.C34366179D427p-1]");

%!# correct use of signed zeros
%!test
%! x = asinh (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.asinh;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     asinh (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.asinh;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (asinh (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.asinh;
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
%! assert (isequaln (asinh (in1), out));
