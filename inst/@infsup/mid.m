## Copyright 2014 Oliver Heimlich
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
## @defmethod {@@infsup} mid (@var{X})
##
## Get the midpoint of interval @var{X}.
##
## If @var{X} is empty, @code{mid (@var{X})} is NaN.
## If @var{X} is entire, @code{mid (@var{X})} is 0.
## If @var{X} is unbounded in one direction, @code{mid (@var{X})} is positive
## or negative @code{realmax ()}.
##
## Accuracy: The result is rounded to the nearest floating point number and
## may thus be exact or not.  However, it is guaranteed that the interval
## @var{X} is tightly enclosed by
## @code{[mid (@var{X}) - rad (@var{X}), mid (@var{X}) + rad (@var{X})]}.
##
## @example
## @group
## mid (infsup (2.5, 3.5))
##   @result{} ans = 3
## @end group
## @end example
## @seealso{@@infsup/inf, @@infsup/sup, @@infsup/rad}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-05

function result = mid (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  ## First divide by 2 and then add, because this will prevent overflow.
  ## The different rounding modes for division will make errors of 2^-1075
  ## with subnormal numbers cancel each other out, or will make the round
  ## to nearest prefer the side that had an underflow error.
  l = mpfr_function_d ('rdivide', -inf, x.inf, 2);
  u = mpfr_function_d ('rdivide', +inf, x.sup, 2);
  result = l + u;

  result(x.inf == -inf) = -realmax ();
  result(x.sup == inf) = realmax ();
  result(isentire (x)) = 0;
  result(isempty (x)) = nan ();

endfunction

%!assert (mid (infsup (-inf, inf)), 0);
%!# from the documentation string
%!assert (mid (infsup (2.5, 3.5)), 3);

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.mid;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     mid (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.mid;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (mid (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.mid;
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
%! assert (isequaln (mid (in1), out));

%!test
%! # Decorated scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.mid;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     mid (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Decorated vector evaluation
%! testcases = testdata.NoSignal.infsupdec.mid;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (mid (in1), out));

%!test
%! # Decorated N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsupdec.mid;
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
%! assert (isequaln (mid (in1), out));
