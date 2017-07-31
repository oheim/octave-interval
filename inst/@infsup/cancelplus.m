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
## @deftypemethod {@@infsup} {@var{Z} =} cancelplus (@var{X}, @var{Y})
##
## Recover interval @var{Z} from intervals @var{X} and @var{Y}, given that one
## knows @var{X} was obtained as the difference @var{Z} - @var{Y}.
##
## Accuracy: The result is a tight enclosure.
##
## @example
## @group
## cancelplus (infsup (2, 3), infsup (1, 1.5))
##   @result{} ans = [3.5, 4]
## @end group
## @end example
## @seealso{@@infsup/cancelminus}
## @end deftypemethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-19

function result = cancelplus (x, y)

  if (nargin ~= 2)
    print_usage ();
    return
  endif

  result = cancelminus (x, -y);

endfunction

%!# from the documentation string
%!assert (cancelplus (infsup (2, 3), infsup (1, 1.5)) == infsup (3.5, 4));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.cancelPlus;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     cancelplus (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.cancelPlus;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (cancelplus (in1, in2), out));

%!test
%! # Decorated scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.cancelPlus;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     cancelplus (testcase.in{1}, testcase.in{2}), ...
%!     testcase.out));
%! endfor

%!test
%! # Decorated vector evaluation
%! testcases = testdata.NoSignal.infsupdec.cancelPlus;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! in2 = vertcat (vertcat (testcases.in){:, 2});
%! out = vertcat (testcases.out);
%! assert (isequaln (cancelplus (in1, in2), out));

%!test
%! # N-dimensional array vector evaluation
%! testcases = testdata.NoSignal.infsupdec.cancelPlus;
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
%! assert (isequaln (cancelplus (in1, in2), out));
