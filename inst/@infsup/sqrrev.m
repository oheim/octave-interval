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
## @deftypemethod {@@infsup} {@var{X} =} sqrrev (@var{C}, @var{X})
## @deftypemethodx {@@infsup} {@var{X} =} sqrrev (@var{C})
##
## Compute the reverse square function.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{x .^ 2 ∈ @var{C}}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## sqrrev (infsup (-2, 1))
##   @result{} ans = [-1, +1]
## @end group
## @end example
## @seealso{@@infsup/sqr}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = sqrrev (c, x)

  if (nargin > 2)
    print_usage ();
    return
  endif

  if (nargin < 2)
    x = infsup (-inf, inf);
  endif
  if (not (isa (c, "infsup")))
    c = infsup (c);
  endif
  if (not (isa (x, "infsup")))
    x = infsup (x);
  endif

  p = sqrt (c);
  n = -p;

  result = union (intersect (p, x), intersect (n, x));

endfunction

%!# from the documentation string
%!assert (sqrrev (infsup (-2, 1)) == infsup (-1, 1));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.sqrRev;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     sqrrev (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.sqrRev;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (sqrrev (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.sqrRev;
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
%! assert (isequaln (sqrrev (in1), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.sqrRevBin;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     sqrrev (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.sqrRevBin;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (sqrrev (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.sqrRevBin;
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
%! assert (isequaln (sqrrev (in1, in2), out));
