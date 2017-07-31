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
## @defop Method {@@infsup} rdivide (@var{X}, @var{Y})
## @defopx Operator {@@infsup} {@var{X} ./ @var{Y}}
##
## Divide all numbers of interval @var{X} by all numbers of @var{Y}.
##
## For @var{X} = 1 compute the reciprocal of @var{Y}.  Thus this function can
## compute @code{recip} as defined by IEEE Std 1788-2015.
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
## @seealso{@@infsup/times}
## @end defop

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

  ## Short-circuit evaluation for 1 ./ x
  if (all (vec (x.inf == 1 & x.sup == 1)))
    result = recip (y);
    ## Resize, if broadcasting is needed
    if (not (size_equal (x.inf, y.inf)))
      result.inf = ones (size (x.inf)) .* result.inf;
      result.sup = ones (size (x.inf)) .* result.sup;
    endif
    return
  endif

  ## Resize, if broadcasting is needed
  if (not (size_equal (x.inf, y.inf)))
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

  l (q1) = mpfr_function_d ('rdivide', -inf, x.sup(q1), y.inf(q1));
  l (q2) = mpfr_function_d ('rdivide', -inf, x.inf(q2), y.inf(q2));
  l (q3) = mpfr_function_d ('rdivide', -inf, x.sup(q3), y.inf(q3));
  l (q4) = -inf;
  l (q5) = mpfr_function_d ('rdivide', -inf, x.sup(q5), y.sup(q5));
  l (q6) = mpfr_function_d ('rdivide', -inf, x.inf(q6), y.sup(q6));
  l (q7) = -inf;
  l (q8) = mpfr_function_d ('rdivide', -inf, x.inf(q8), y.sup(q8));
  l (q9) = mpfr_function_d ('rdivide', -inf, x.sup(q9), y.sup(q9));
  l (q10) = mpfr_function_d ('rdivide', -inf, x.inf(q10), y.inf(q10));
  u (q1) = mpfr_function_d ('rdivide', +inf, x.inf(q1), y.sup(q1));
  u (q2) = mpfr_function_d ('rdivide', +inf, x.sup(q2), y.sup(q2));
  u (q3) = inf;
  u (q4) = mpfr_function_d ('rdivide', +inf, x.sup(q4), y.sup(q4));
  u (q5) = mpfr_function_d ('rdivide', +inf, x.inf(q5), y.inf(q5));
  u (q6) = mpfr_function_d ('rdivide', +inf, x.sup(q6), y.inf(q6));
  u (q7) = mpfr_function_d ('rdivide', +inf, x.inf(q7), y.inf(q7));
  u (q8) = inf;
  u (q9) = mpfr_function_d ('rdivide', +inf, x.inf(q9), y.sup(q9));
  u (q10) = mpfr_function_d ('rdivide', +inf, x.sup(q10), y.inf(q10));

  entireresult = (y.inf < 0 & y.sup > 0) | (x.inf < 0 & x.sup > 0 & ...
                                            (y.inf == 0 | y.sup == 0));
  l(entireresult) = -inf;
  u(entireresult) = inf;

  zeroresult = x.inf == 0 & x.sup == 0;
  l(zeroresult) = u(zeroresult) = 0;

  l(l == 0) = -0;

  emptyresult = isempty (x) | isempty (y) | (y.inf == 0 & y.sup == 0);
  l(emptyresult) = inf;
  u(emptyresult) = -inf;

  result = infsup ();
  result.inf = l;
  result.sup = u;

endfunction

function result = recip (x)
  ## Compute the reciprocal of @var{X}.
  ##
  ## The result is equivalent to @code{1 ./ @var{X}}, but is computed more
  ## efficiently.
  ##
  ## Accuracy: The result is a tight enclosure.

  l = inf (size (x.inf));
  u = -l;

  ## Fix signs to make use of limit values for 1 ./ x.
  x.inf(x.inf == 0) = +0;
  x.sup(x.sup == 0) = -0;

  select = (x.inf >= 0 | x.sup <= 0) & ...
                                # undefined for x = [0, 0]
           not (x.inf == 0 & x.sup == 0) & ...
                                # x is not empty
           x.inf < inf;
  if (any (select(:)))
    ## recip is monotonically decreasing
    l(select) = mpfr_function_d ('rdivide', -inf, 1, x.sup(select));
    u(select) = mpfr_function_d ('rdivide', +inf, 1, x.inf(select));
  endif

  ## singularity at x = 0
  select = x.inf < 0 & x.sup > 0;
  if (any (select(:)))
    l(select) = -inf;
    u(select) = +inf;
  endif

  l(l == 0) = -0;

  result = infsup ();
  result.inf = l;
  result.sup = u;

endfunction

%!# from the documentation string
%!assert (infsup (2, 3) ./ infsup (1, 2) == infsup (1, 3));

%!assert (1 ./ infsup (1, 4) == infsup (0.25, 1));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.div;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     rdivide (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.div;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (rdivide (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.div;
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
%! assert (isequaln (rdivide (in1, in2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.recip;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     rdivide (1, testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.recip;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (rdivide (1, in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.recip;
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
%! assert (isequaln (rdivide (1, in1), out));
