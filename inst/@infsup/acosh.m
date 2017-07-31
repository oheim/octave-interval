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
## @defmethod {@@infsup} acosh (@var{X})
##
## Compute the inverse hyperbolic cosine.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## acosh (infsup (2))
##   @result{} ans ⊂ [1.3169, 1.317]
## @end group
## @end example
## @seealso{@@infsup/cosh}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-07

function x = acosh (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  persistent domain = infsup (1, inf);
  x = intersect (x, domain);

  ## acosh is monotonically increasing from (1, 0) to (inf, inf)
  l = mpfr_function_d ('acosh', -inf, x.inf);
  u = mpfr_function_d ('acosh', +inf, x.sup);
  l(l == 0) = -0;

  emptyresult = isempty (x);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  x.inf = l;
  x.sup = u;

endfunction

%!# Empty interval
%!assert (acosh (infsup ()) == infsup ());

%!# Singleton intervals
%!assert (acosh (infsup (0)) == infsup ());
%!assert (acosh (infsup (1)) == infsup (0));
%!test
%! x = infsup (1 : 3 : 100);
%! assert (min (subset (acosh (x), log (x + sqrt (x + 1) .* sqrt (x - 1)))));

%!# Bounded intervals
%!assert (acosh (infsup (0, 1)) == infsup (0));

%!# Unbounded intervals
%!assert (acosh (infsup (-inf, 0)) == infsup ());
%!assert (acosh (infsup (-inf, 1)) == infsup (0));
%!assert (acosh (infsup (0, inf)) == infsup (0, inf));
%!assert (acosh (infsup (1, inf)) == infsup (0, inf));
%!assert (subset (acosh (infsup (2, inf)), infsup (1, inf)));

%!# from the documentation string
%!assert (acosh (infsup (2)) == "[0x1.5124271980434, 0x1.5124271980435]");

%!# correct use of signed zeros
%!test
%! x = acosh (infsup (1));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.acosh;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     acosh (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.acosh;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (acosh (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.acosh;
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
%! assert (isequaln (acosh (in1), out));
