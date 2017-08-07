## Copyright 2014-2016 Oliver Heimlich
## Copyright 2017 Joel Dahne
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
## @defmethod {@@infsup} iscommoninterval (@var{X})
##
## Check if the interval is a common interval, that is a nonemty, closed
## bounded real interval.
##
## Common intervals are used in class Moore interval arithmetic and are
## flavor-independent in IEEE Std 1788-2015 interval arithmetic.
##
## Evaluated on interval arrays, this functions is applied element-wise.
##
## @seealso{@@infsup/eq, @@infsup/isentire, @@infsup/isempty, @@infsup/issingleton}
## @end defmethod

## Author: Oliver Heimlich
## Keywords: interval
## Created: 2014-10-23

function result = iscommoninterval (x)

  if (nargin ~= 1)
    print_usage ();
    return
  endif

  result = isfinite (x.inf) & isfinite (x.sup);

endfunction

%!assert (iscommoninterval (infsup (2, 3)));
%!assert (not (iscommoninterval (infsup (2, inf))));
%!assert (not (iscommoninterval (infsup ())));
%!assert (not (iscommoninterval (infsup (-inf, inf))));

%!assert (iscommoninterval (infsupdec (2, 3, "com")));
%!assert (iscommoninterval (infsupdec (2, 3, "trv")));
%!assert (not (iscommoninterval (infsupdec (2, inf, "trv"))));
%!assert (not (iscommoninterval (empty ())));
%!assert (not (iscommoninterval (entire ())));

%!warning assert (not (iscommoninterval (infsupdec (2, 1))));

%!shared testdata
%! # Load compiled test data (from src/test/*.itl)
%! testdata = load (file_in_loadpath ("test/itl.mat"));

%!test
%! # Scalar evaluation
%! testcases = testdata.NoSignal.infsup.isCommonInterval;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     iscommoninterval (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Vector evaluation
%! testcases = testdata.NoSignal.infsup.isCommonInterval;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (iscommoninterval (in1), out));

%!test
%! # N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.isCommonInterval;
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
%! assert (isequaln (iscommoninterval (in1), out));

%!test
%! # Decorated scalar evaluation
%! testcases = testdata.NoSignal.infsupdec.isCommonInterval;
%! for testcase = [testcases]'
%!   assert (isequaln (...
%!     iscommoninterval (testcase.in{1}), ...
%!     testcase.out));
%! endfor

%!test
%! # Decorated vector evaluation
%! testcases = testdata.NoSignal.infsupdec.isCommonInterval;
%! in1 = vertcat (vertcat (testcases.in){:, 1});
%! out = vertcat (testcases.out);
%! assert (isequaln (iscommoninterval (in1), out));

%!test
%! # Decorated N-dimensional array evaluation
%! testcases = testdata.NoSignal.infsup.isCommonInterval;
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
%! assert (isequaln (iscommoninterval (in1), out));
