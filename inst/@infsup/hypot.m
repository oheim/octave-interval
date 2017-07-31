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
## @defmethod {@@infsup} hypot (@var{X}, @var{Y})
##
## Compute the euclidean norm.
##
## @code{hypot (@var{x}, @var{y}) = sqrt (@var{x}^2 + @var{y}^2)}
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## x = infsup (2, 3);
## y = infsup (1, 2);
## hypot (x, y)
##   @result{} ans ⊂ [2.236, 3.6056]
## @end group
## @end example
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2015-02-20

function x = hypot (x, y)

  if (nargin ~= 2)
    print_usage ();
    return
  endif
  if (not (isa (x, "infsup")))
    x = infsup (x);
  endif
  if (not (isa (y, "infsup")))
    y = infsup (y);
  endif

  l = mpfr_function_d ('hypot', -inf, mig (x), mig (y));
  u = mpfr_function_d ('hypot', +inf, mag (x), mag (y));

  emptyresult = isempty (x) | isempty (y);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  l(l == 0) = -0;

  x.inf = l;
  x.sup = u;

endfunction

%!# from the documentation string
%!assert (hypot (infsup (2, 3), infsup (1, 2)) == "[0x1.1E3779B97F4A7p1, 0x1.CD82B446159F4p1]");

%!# correct use of signed zeros
%!test
%! x = hypot (infsup (0), infsup (0));
%! assert (signbit (inf (x)));
%! assert (not (signbit (sup (x))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.hypot;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     hypot (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.hypot;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (hypot (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.hypot;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2)
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! in2 = reshape ([in2; in2(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (hypot (in1, in2), out));
