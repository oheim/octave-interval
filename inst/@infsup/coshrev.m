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
## @deftypemethod {@@infsup} {@var{X} =} coshrev (@var{C}, @var{X})
## @deftypemethodx {@@infsup} {@var{X} =} coshrev (@var{C})
##
## Compute the reverse hyperbolic cosine function.
##
## That is, an enclosure of all @code{x ∈ @var{X}} where
## @code{cosh (x) ∈ @var{C}}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## coshrev (infsup (-2, 1))
##   @result{} ans = [0]
## @end group
## @end example
## @seealso{@@infsup/cosh}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-13

function result = coshrev (c, x)

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

  p = acosh (c);
  n = uminus (p);

  result = union (intersect (p, x), intersect (n, x));

endfunction

%!# from the documentation string
%!assert (coshrev (infsup (-2, 1)) == 0);

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.coshRev;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     coshrev (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.coshRev;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (coshrev (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.coshRev;
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
%! assert (isequaln (coshrev (in1), out));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.coshRevBin;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     coshrev (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.coshRevBin;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (coshrev (in1, in2), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.coshRevBin;
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
%! assert (isequaln (coshrev (in1, in2), out));
