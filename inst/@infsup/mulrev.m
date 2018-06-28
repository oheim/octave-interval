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
## @deftypemethod {@@infsup} {@var{X} =} mulrev (@var{B}, @var{C}, @var{X})
## @deftypemethodx {@@infsup} {@var{X} =} mulrev (@var{B}, @var{C})
## @deftypemethodx {@@infsup} {[@var{U}, @var{V}] =} mulrev (@var{B}, @var{C})
## @deftypemethodx {@@infsup} {[@var{U}, @var{V}] =} mulrev (@var{B}, @var{C}, @var{X})
##
## Compute the reverse multiplication function or the two-output division.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{x .* b ∈ @var{C}} for any @code{b ∈ @var{B}}.
##
## This function is similar to interval division @code{@var{C} ./ @var{B}}.
## However, it treats the case 0/0 as “any real number” instead of “undefined”.
##
## Interval division, considered as a set, can have zero, one or two disjoint
## connected components as a result.  If called with two output parameters,
## this function returns the components separately.  @var{U} contains the
## negative or unique component, whereas @var{V} contains the positive
## component in cases with two components.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## c = infsup (1);
## b = infsup (-inf, inf);
## [u, v] = mulrev (b, c)
##   @result{}
##     u = [-inf, 0]
##     v = [0, inf]
## @end group
## @end example
## @seealso{@@infsup/times}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function [u, v] = mulrev (b, c, x)

  if (nargin < 2 || nargin > 3)
    print_usage ();
    return
  endif
  if (nargin < 3)
    x = infsup (-inf, inf);
  endif
  if (not (isa (b, "infsup")))
    b = infsup (b);
  endif
  if (not (isa (c, "infsup")))
    c = infsup (c);
  endif
  if (not (isa (x, "infsup")))
    x = infsup (x);
  endif

  ## Resize, if broadcasting is needed
  if (not (size_equal (b.inf, c.inf)))
    b.inf = ones (size (c.inf)) .* b.inf;
    b.sup = ones (size (c.inf)) .* b.sup;
    c.inf = ones (size (b.inf)) .* c.inf;
    c.sup = ones (size (b.inf)) .* c.sup;
  endif

  u = v = x;
  u.inf = v.inf = inf (size (b.inf));
  u.sup = v.sup = -inf (size (b.inf));

  emptyresult = b.inf == inf | c.inf == inf ...
                | (b.inf == 0 & b.sup == 0 & (c.sup < 0 | c.inf > 0)); # x * 0 ~= 0
  twocomponents = b.inf < 0 & b.sup > 0 & not (emptyresult) & ...
                  (c.sup < 0 | c.inf > 0);
  onecomponent = not (twocomponents) & not (emptyresult);

  u.inf(twocomponents) = -inf;
  v.sup(twocomponents) = inf;
  dom = twocomponents & c.inf <= 0 & c.sup >= 0;
  u.sup(dom) = v.inf(dom) = 0;
  dom = twocomponents & c.inf > 0;
  if (not (isempty (dom)))
    u.sup(dom) = mpfr_function_d ('rdivide', +inf, c.inf(dom), b.inf(dom));
    v.inf(dom) = mpfr_function_d ('rdivide', -inf, c.inf(dom), b.sup(dom));
  endif
  dom = twocomponents & c.sup < 0;
  if (not (isempty (dom)))
    u.sup(dom) = mpfr_function_d ('rdivide', +inf, c.sup(dom), b.sup(dom));
    v.inf(dom) = mpfr_function_d ('rdivide', -inf, c.sup(dom), b.inf(dom));
  endif

  dom = onecomponent & b.inf >= 0 & c.inf >= 0;
  if (not (isempty (dom)))
    b.inf(dom & b.inf == 0) = +0;
    c.inf(dom & c.inf == 0) = +0;
    u.inf(dom) = mpfr_function_d ('rdivide', -inf, c.inf(dom), b.sup(dom));
    u.sup(dom) = mpfr_function_d ('rdivide', +inf, c.sup(dom), b.inf(dom));
  endif
  dom = onecomponent & b.sup <= 0 & c.inf >= 0;
  if (not (isempty (dom)))
    b.sup(dom & b.sup == 0) = -0;
    c.inf(dom & c.inf == 0) = +0;
    u.inf(dom) = mpfr_function_d ('rdivide', -inf, c.sup(dom), b.sup(dom));
    u.sup(dom) = mpfr_function_d ('rdivide', +inf, c.inf(dom), b.inf(dom));
  endif
  dom = onecomponent & b.inf >= 0 & c.sup <= 0;
  if (not (isempty (dom)))
    b.inf(dom & b.inf == 0) = +0;
    c.sup(dom & c.sup == 0) = -0;
    u.inf(dom) = mpfr_function_d ('rdivide', -inf, c.inf(dom), b.inf(dom));
    u.sup(dom) = mpfr_function_d ('rdivide', +inf, c.sup(dom), b.sup(dom));
  endif
  dom = onecomponent & b.sup <= 0 & c.sup <= 0;
  if (not (isempty (dom)))
    b.sup(dom & b.sup == 0) = -0;
    c.sup(dom & c.sup == 0) = -0;
    u.inf(dom) = mpfr_function_d ('rdivide', -inf, c.sup(dom), b.inf(dom));
    u.sup(dom) = mpfr_function_d ('rdivide', +inf, c.inf(dom), b.sup(dom));
  endif
  dom = onecomponent & c.inf < 0 & c.sup > 0 & b.inf > 0;
  if (not (isempty (dom)))
    u.inf(dom) = mpfr_function_d ('rdivide', -inf, c.inf(dom), b.inf(dom));
    u.sup(dom) = mpfr_function_d ('rdivide', +inf, c.sup(dom), b.inf(dom));
  endif
  dom = onecomponent & c.inf < 0 & c.sup > 0 & b.sup < 0;
  if (not (isempty (dom)))
    u.inf(dom) = mpfr_function_d ('rdivide', -inf, c.sup(dom), b.sup(dom));
    u.sup(dom) = mpfr_function_d ('rdivide', +inf, c.inf(dom), b.sup(dom));
  endif
  dom = onecomponent & b.inf <= 0 & b.sup >= 0 & c.inf <= 0 & c.sup >= 0;
                                # x * 0 == 0
  u.inf(dom) = -inf;
  u.sup(dom) = inf;

  u.inf(u.inf == 0) = -0;
  u.sup(u.sup == 0) = +0;
  v.inf(v.inf == 0) = -0;
  v.sup(v.sup == 0) = +0;

  ## Intersect u and v with x
  u.inf = max (u.inf, x.inf);
  u.sup = min (u.sup, x.sup);
  v.inf = max (v.inf, x.inf);
  v.sup = min (v.sup, x.sup);

  if (nargout < 2)
    u.inf(twocomponents) = min (u.inf(twocomponents), v.inf(twocomponents));
    u.sup(twocomponents) = max (u.sup(twocomponents), v.sup(twocomponents));
    emptyresult = u.inf > u.sup;
    u.inf(emptyresult) = inf;
    u.sup(emptyresult) = -inf;
  else
    empty_u = u.inf > u.sup;
    u.inf(empty_u) = inf;
    u.sup(empty_u) = -inf;
    empty_v = v.inf > v.sup;
    v.inf(empty_v) = inf;
    v.sup(empty_v) = -inf;
    ## It can happen that the twocomponents result has only one component,
    ## because x is positive for example.  Then, only one component shall be
    ## returned
    swap = twocomponents & isempty (u) & not (isempty (v));
    [u.inf(swap), u.sup(swap), v.inf(swap), ...
     v.sup(swap)] = deal (v.inf(swap), v.sup(swap), u.inf(swap), u.sup(swap));
  endif

endfunction

%!#IEEE Std 1788-2015 mulRevToPair examples
%!test
%!  [u, v] = mulrev (infsup (0), infsup (1, 2));
%!  assert (isempty (u) & isempty (v));
%!test
%!  [u, v] = mulrev (infsup (0), infsup (0, 1));
%!  assert (isentire (u) & isempty (v));
%!test
%!  [u, v] = mulrev (infsup (1), infsup (1, 2));
%!  assert (eq (u, infsup (1, 2)) & isempty (v));
%!test
%!  [u, v] = mulrev (infsup (1, inf), infsup (1));
%!  assert (eq (u, infsup (0, 1)) & isempty (v));
%!test
%!  [u, v] = mulrev (infsup (-1, 1), infsup (1, 2));
%!  assert (eq (u, infsup (-inf, -1)) & eq (v, infsup (1, inf)));
%!test
%!  [u, v] = mulrev (infsup (-inf, inf), infsup (1));
%!  assert (eq (u, infsup (-inf, 0)) & eq (v, infsup (0, inf)));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.mulRevToPair1;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     nthargout (1, 2, @mulrev, testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.mulRevToPair1;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (nthargout (1, 2, @mulrev, in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.mulRevToPair1;
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
%! assert (isequaln (nthargout (1, 2, @mulrev, in1, in2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.mulRevToPair2;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     nthargout (2, @mulrev, testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.mulRevToPair2;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (nthargout (2, @mulrev, in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.mulRevToPair2;
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
%! assert (isequaln (nthargout (2, @mulrev, in1, in2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.mulRev;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     mulrev (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.mulRev;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (mulrev (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.mulRev;
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
%! assert (isequaln (mulrev (in1, in2), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.mulRevTen;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     mulrev (testcase.in{1}, testcase.in{2}, testcase.in{3}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.mulRevTen;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! in3 = vertcat (vertcat (testcases.in){:, 3});
%! out = vertcat (testcases.out);
%! assert (isequaln (mulrev (in1, in2, in3), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.mulRevTen;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! in3 = vertcat (vertcat (testcases.in){:, 3});
%! out = vertcat (testcases.out);
%! # Reshape data
%! i = -1;
%! do
%!   i = i + 1;
%!   testsize = factor (numel (in1) + i);
%! until (numel (testsize) > 2)
%! in1 = reshape ([in1; in1(1:i)], testsize);
%! in2 = reshape ([in2; in2(1:i)], testsize);
%! in3 = reshape ([in3; in3(1:i)], testsize);
%! out = reshape ([out; out(1:i)], testsize);
%! assert (isequaln (mulrev (in1, in2, in3), out));
