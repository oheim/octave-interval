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
## @defmethod {@@infsup} sup (@var{X})
## @comment DO NOT SYNCHRONIZE DOCUMENTATION STRING
##
## Get the (least) upper boundary for all numbers of interval @var{X}.
##
## If @var{X} is empty, @code{sup (@var{X})} is negative infinity.
##
## Accuracy: The result is exact.
##
## @example
## @group
## sup (infsup (2.5, 3.5))
##   @result{} ans = 3.5000
## @end group
## @end example
## @seealso{@@infsup/inf, @@infsup/mid}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-27

function result = sup (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  result = x.sup;

endfunction

%!# from the documentation string
%!assert (sup (infsup (2.5, 3.5)), 3.5);

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.sup;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     sup (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.sup;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (sup (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.sup;
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
%! assert (isequaln (sup (in1), out));
