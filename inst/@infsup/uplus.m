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
## @defop Method {@@infsup} uplus (@var{X})
## @defopx Operator {@@infsup} {+@var{X}}
##
## Return the interval itself.
##
## Accuracy: The result is exact.
##
## @example
## @group
## x = infsup (2, 3);
## + x
##   @result{} ans = [2, 3]
## @end group
## @end example
## @seealso{@@infsup/uminus}
## @end defop

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-09-30

function x = uplus (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

endfunction

%!# from the documentation string
%!assert (+infsup (2, 3) == infsup (2, 3));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.pos;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     uplus (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.pos;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (uplus (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.pos;
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
%! assert (isequaln (uplus (in1), out));

%!test
%! # Decorated scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.pos;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     uplus (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Decorated vector evaluation
%! testcases = testdata.NoSignal.infsupdec.pos;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (uplus (in1), out));

%!test
%! # Decorated N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.pos;
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
%! assert (isequaln (uplus (in1), out));
