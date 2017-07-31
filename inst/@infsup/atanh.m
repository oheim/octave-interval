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
## @defmethod {@@infsup} atanh (@var{X})
##
## Compute the inverse hyperbolic tangent.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## atanh (infsup (.5))
##   @result{} ans ⊂ [0.5493, 0.54931]
## @end group
## @end example
## @seealso{@@infsup/tanh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function x = atanh (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  x = intersect (x, infsup (-1, 1));

  ## atanh is monotonically increasing between (-1, -inf) and (1, inf)
  l = mpfr_function_d ('atanh', -inf, x.inf);
  u = mpfr_function_d ('atanh', +inf, x.sup);

  emptyresult = isempty (x) | x.sup <= -1 | x.inf >= 1;
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  l(l == 0) = -0;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (atanh (infsup (.5)) == "[0x1.193EA7AAD030Ap-1, 0x1.193EA7AAD030Bp-1]");

%!# correct use of signed zeros
%!test
%! x = atanh (infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.atanh;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     atanh (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.atanh;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (atanh (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.atanh;
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
%! assert (isequaln (atanh (in1), out));
