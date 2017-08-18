## Copyright 2014-2017 Oliver Heimlich
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
## @defmethod {@@infsup} mig (@var{X})
##
## Get the mignitude of numbers in interval @var{X}, that is the minimum of
## absolute values for each element.
##
## If @var{X} is empty, @code{mig (@var{X})} is NaN.
##
## Accuracy: The result is exact.
##
## @example
## @group
## mig (infsup (-2, -1))
##   @result{} ans = 1
## @end group
## @end example
## @seealso{@@infsup/mag, @@infsup/inf, @@infsup/sup}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function result = mig (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  result = min (abs (x.inf), abs (x.sup));
  result(sign (x.inf) ~= sign (x.sup)) = 0;
  result(x.inf > x.sup) = nan ();

endfunction

%!assert (mig (infsup (-1, 2)), 0);
%!assert (mig (infsup (-42, -23)), 23);

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.mig;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     mig (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.mig;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (mig (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.mig;
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
%! assert (isequaln (mig (in1), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.mig;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     mig (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsupdec.mig;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (mig (in1), out));

%!test
%! # Decorated N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.mig;
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
%! assert (isequaln (mig (in1), out));
